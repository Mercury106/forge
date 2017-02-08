class Version < ActiveRecord::Base
  module DropboxDeployer
    extend ActiveSupport::Concern

    module ClassMethods
      def import_from_dropbox_without_delay(id)
        version = Version.find(id)
        version.import_from_dropbox_without_delay()
      end
    end

    def dropbox_directory
      @dropbox_directory ||= Dir.mktmpdir
    end

    def import_from_dropbox_without_delay

      return false unless site.dropbox_path

      self.update_attributes :percent_deployed => 1
      download_from_dropbox()
      self.update_attributes :percent_deployed => 2
      create_zip()

      # I can't figure out a way to force the site to deploy without enqueueing it.

      # puts "Reloading the site.."
      # self.reload()
      # site = self.site

      # puts "Site's current version id..."
      # site.current_version = self
      # site.force_deploy = false
      # site.save()

      # puts "Deploying the site now..."
      # self.site.reload.deploy_without_delay
    end

    def import_from_dropbox
      ImportFromDropboxWorker.perform_async(id) if site.dropbox_path.present?
    end

  private

    def create_zip
      zipfile_name = File.join(Dir.mktmpdir, 'dropbox-zip-file.zip')
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        Dir[File.join(dropbox_directory, "**/*")].each do |path|

          next if exclude_file?(path)

          filename = path[dropbox_directory.length..-1]
          filename = filename[1..-1]

          # Two arguments:
          # - The name of the file as it will appear in the archive
          # - The original file, including the path to find it
          puts "Adding #{filename} to #{zipfile_name}"
          zipfile.add(filename, File.open(path))
        end
      end
      puts "Created zipfile: #{zipfile_name}"
      self.upload = File.open(zipfile_name)
      self.save()
    end

    def download_from_dropbox
      download_contents(site.dropbox_path)
    end

    def exclude_file?(filename)
      return true if filename =~ /\.git/
      return true if filename =~ /\.DS_Store/
      return true if filename =~ /\.sass-cache/

      false
    end

    def download_dropbox_asset(file_url_path, local_path)

      return false if exclude_file?(local_path)
      
      Net::HTTP.start("api-content.dropbox.com", :use_ssl => true) do |http|
        begin
          file = open(local_path, 'wb')
          http.request_get(URI.encode(file_url_path)) do |response|
            response.read_body do |segment|
              file.write(segment)
            end
          end
        ensure
          file.close
        end
      end
    end

    def download_contents(path)
      url = "https://api.dropbox.com/1/metadata/dropbox#{URI.encode path}?access_token=#{site.user.dropbox_token}"
      json = JSON.parse(open(url).read)

      json['contents'].each do |contents|

        next if exclude_file?(contents['path'])

        path          = contents['path']
        relative_path = contents['path'][site.dropbox_path.length..-1]

        if contents['is_dir']
          download_contents(contents['path'])
        else
          file_url_path = "/1/files/dropbox/#{path}?access_token=#{site.user.dropbox_token}"
          local_path = File.join(dropbox_directory, relative_path)
          FileUtils.mkdir_p(File.dirname(local_path))
          download_dropbox_asset(file_url_path, local_path)
        end
      end
    end
    
  end
end

require 'json'
require "zip"