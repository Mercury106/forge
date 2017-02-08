#!/usr/local/bin/ruby

require "rubygems"
require "open-uri"
require "pathname"
require "tmpdir"
require "fileutils"
require "zip/filesystem"

class VersionDeployer

  attr_accessor :version, :site, :url, :file
  attr_accessor :local_directory, :root_path
  attr_accessor :deploy_slug

  def initialize(options={})
    @files = []
    @root_path = nil

    self.version = options.delete :version
    self.deploy_slug = (options.delete(:deploy_slug) || Time.now.to_i.to_s)
    self.local_directory = options.delete(:local_directory) || Dir.mktmpdir
    self.url = options.delete :url
  end

  def self.from_version(version)
    instance = new
    instance.url = version.site.url
    instance.version = version
    instance
  end

  def deploy
    begin
      perform_deploy
    rescue Exception => e
      ExceptionNotifier.notify_exception(e)
      WebhookTriggerWorker.perform_async('deploy_failure', version.site.id)
      Rails.logger.error(e.message)
      ConsoleLogger.fail(e.message)
    end
  end

  def touch_site
    if self.version && self.version.site
      self.version.site.update_attribute :deployed_at, Time.now
    end
  end

  def un_deploy
    VersionUploader.new(:url => url, :deploy_slug => deploy_slug).un_deploy()
  end

  def clean
    # TODO: Cleanup files that weren't listed.
  end


  def parse
    [
      # DeploymentParser::HammerProjectParser,
      DeploymentParser::FileEncodingConverter,
      DeploymentParser::HammerTagParser,
      DeploymentParser::AssetPathParser,
      DeploymentParser::SquishParser,
      DeploymentParser::AssetPathParser,
      DeploymentParser::LinkParser,
      DeploymentParser::JavascriptParser,
      # DeploymentParser::ImageMinifier,
      DeploymentParser::IgnoredFilesParser,
      DeploymentParser::SvgParser,
      DeploymentParser::ForgeCdnTagAdderParser,
      DeploymentParser::FormParser,
      DeploymentParser::SitercParser
    ].each do |parser_class|
      begin
        # log "Running #{parser_class.name.split('::').last.split(/(?=[A-Z])/).join(' ')}", 'parent'
        parser = prepare_parser(parser_class, self.version)
        parser.process() if parser
      rescue => e
        puts e
        if version
          version.update_attribute :state, "Error in #{parser_class.to_s.split("::")[-1].titleize}."
        end
        un_deploy()
        ConsoleLogger.fail(e.message)
        raise e
      end
    end
  end

  def url
    original_url = @url
    if original_url.starts_with? "www."
      original_url = original_url[4..-1]
    end
    original_url
  end

private

  def perform_deploy
    unless ConsoleLogger.status_sent? # forge console title
      ConsoleLogger.status("Deploying #{url} [version ##{version.scoped_id}]")
    end
    # compile hammer projects online
    if version.site.hammer_enabled && version.hammer_archive_url.blank?
      ConsoleLogger.ok('[hammer online] start project compilation')
      HammerOnlineWorker.perform_async(version.site.id)
      return
    end
    puts "hahaha"
    ConsoleLogger.ok('unzipping')
    unzip()
    parse()
    ConsoleLogger.ok('uploading')
    upload()
    ConsoleLogger.ok('touching site')
    touch_site()
    ConsoleLogger.ok('saving deploy slug')
    save_deploy_slug()
    ConsoleLogger.success('finished')
    WebhookTriggerWorker.perform_async('deploy_success', version.site.id)
  end

  def upload_file(file_path, file_changed)
    return if File.directory?(file_path)
    here = Pathname.new(@local_directory)
    filename = Pathname.new(file_path).relative_path_from(here)
    uploader = VersionUploader.new({
      url: self.url,
      filename: filename,
      local_file_path: file_path,
      deploy_slug: self.deploy_slug,
      file_changed: file_changed,
      previous_slug: self.version.site.previous_version.try(:deploy_slug)
    })
    uploader.upload()
  end

  def sorted_files
    path = File.join(@local_directory, '**/*')
    files = Dir.glob(path).sort do |file|
      (file.end_with?('.html') or file.end_with?(".htm")) ? 1 : 0
    end

    files.select! {|file|
      !file.end_with? ".scssc"
    }

    files
  end

  def deployment_mutex
    @key ||= "site:#{self.version.site_id}:deployed_at"
    if !@deploy_started_at
      Rails.cache.write(@key, @deploy_started_at = Time.now)
    else
      Rails.cache.read(@key) == @deploy_started_at
    end
  end

  def upload
    require 'threadpool'

    if Rails.env.production?
      threads = 4
    else
      threads = 2
    end

    p = Pool.new(threads)
    sorted_files.each do |file_path|
      next if File.directory?(file_path)
      p.schedule do
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          if deployment_mutex
            upload_file(file_path, file_changed?(file_path))
            increment_percentage(file_path)
          else
            break
          end
        end
      end
    end

    p.shutdown
    ActiveRecord::Base.connection_pool.reap

    # This is so we can check for percent_deployed > 100.
    # TODO: This might be better to have as an enumerable value so we can change it later.

    PercentDeployedWorker.perform_async(version.id, 1001)
    # version.update_attributes percent_deployed: 1001

    version.update_column :state, 'Live!'
  end

  def file_changed?(file_path)
    return true if version.site.previous_version.try(:deploy_slug).blank? || \
                   (file_path.ends_with?('.html') || file_path.ends_with?('.htm'))
    file_name = file_path.split('/').drop(3).join('/')
    file_hash = version.file_hash[file_name] || \
                Digest::MD5.hexdigest(File.read(file_path))
    old_file_hash = version.site.previous_version.file_hash[file_name]
    file_hash != old_file_hash
  end

  def increment_percentage(file_path)
    # TODO: This could be size using file_path.
    @files_uploaded ||= 0
    @files_uploaded += 1

    @bytes_uploaded ||= 0
    @bytes_uploaded += File.size(file_path)

    # if @bytes
    #   percent = @bytes_uploaded / @bytes
    # else
      @total_files ||= sorted_files.size
      percent = @files_uploaded.to_f / @total_files.to_f * 100
    # end

    # puts "Percent deployed: #{percent}"

    percent = percent.round()
    percent = 1 if percent <= 0

    PercentDeployedWorker.perform_async(version.id, percent)
  end

  def prepare_parser(klass, args)
    parser = klass.new(@local_directory, args)
    if parser.respond_to? :set_assets_location_root
      parser.set_assets_location_root assets_location_root
    end

    if parser.respond_to? :set_slug
      parser.set_slug @deploy_slug
    end

    if parser.respond_to? :set_url
      parser.set_url(self.url)
    end

    if klass == DeploymentParser::SquishParser
      return false if !@version.try(:site).try(:squish)
    end

    parser
  end

  def assets_location_root
    cdn_host = ENV['CDN_HOST'] ? ENV['CDN_HOST'] : "#{ENV['AWS_BUCKET']}.s3.amazonaws.com"
    "http://#{cdn_host}/#{url}/#{@deploy_slug}"
  end

  #### Local zipped files

  def zipped_file
    return @zipped_file if @zipped_file
    if !@file
      if version.hammer_archive_url.blank?
        version_url = @version.upload.url
      else
        version_url = version.hammer_archive_url
      end
      @file ||= open(version_url)
    end
    @zipped_file ||= Zip::File.open(file)
  end

  ### Zip::File operations

  # The names of all the files in the zip file.
  def zipfile_filenames
    zipped_file.entries.collect(&:name)
  end
  # In a MAC OSX zip file, we have __MACOSX and the other folder name. This gives the other folder name.
  def root_path
    root_filenames = zipfile_filenames.select { |file| file.split("/").length == 1 }.collect(&:to_s)
    if root_filenames.length == 1 || root_filenames.length == 2 && root_filenames.include?('__MACOSX/')
      root_filenames.delete('__MACOSX/')
      other_folder_name = root_filenames[0]
      @root_path = other_folder_name if other_folder_name[-1] == "/"
    end
    @root_path
  end

  # The adjusted filenames of the files in the zipfile, without the Build folder prefix.
  # index.html, assets/images/logo.png
  def filenames
    return @filenames if @filenames
    filenames = zipfile_filenames

    filenames = filenames.select do |zipfile|
      !(zipfile =~ /__MACOSX/ or zipfile =~ /\.DS_Store/ or zipfile.end_with? "/" or zipfile =~ /\.git/)
    end

    if root_path && root_path.length > 0
      root_path_length = root_path.length
      root_path_to_s = root_path.to_s
      new_filenames = []
      filenames.each do |filename|
        next unless filename
        next if filename =~ /.git/
        if filename.start_with?(root_path_to_s)
          filename = filename[root_path_length..-1]
        end
        new_filenames << filename
      end
      filenames = new_filenames
    end

    @filenames = filenames
  end

  # Only the HTML filenames.
  def html_filenames
    filenames.select {|filename|
      filename != "" && (filename.end_with?(".html") or filename.end_with?(".htm"))
    }
  end

  def unzip

    FileUtils.rm_rf @local_directory
    FileUtils.mkdir_p @local_directory

    files = []

    hash = {}

    filenames.each do |filename|

      # Build/index.html
      zipfile_filename = File.join([@root_path, filename].compact)

      # tmp/index.html
      local_file_path = File.join(@local_directory, filename)

      # local_file_path = local_file_path.split("?")[0]

      FileUtils.mkdir_p(File.dirname(local_file_path))

      # Build/index.html -> tmp/index.html
      begin
        zipped_file.extract(zipfile_filename, local_file_path)
      rescue => e
        puts "Error unzipping #{zipfile_filename} to #{local_file_path}"
        ConsoleLogger.fail("Error unzipping #{zipfile_filename} to #{local_file_path}")
      end

      if File.exist? local_file_path
        hash[filename.encode_utf8] = Digest::MD5.file(local_file_path).to_s
      end
    end

    version.file_hash = hash
    version.save()
    @bytes = `du -s #{@local_directory}`.split("\t")[0].to_i rescue nil
  end

  def save_deploy_slug
    version.update_column('deploy_slug', deploy_slug)
  end
end
