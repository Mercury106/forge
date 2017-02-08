# S3 stuff goes in here.

require "stringio"
require "zlib"

class VersionUploader
  attr_accessor :filename, :local_file_path, :deploy_slug, :url,
                :file_changed, :previous_slug
  
  def initialize(options={})
    self.filename = options.delete(:filename).to_s
    self.deploy_slug = options.delete(:deploy_slug)
    self.local_file_path = options.delete(:local_file_path)
    self.url = options.delete(:url)
    self.file_changed = options.delete(:file_changed)
    self.previous_slug = options.delete(:previous_slug)

    # We want the URL to always be www-free when we deploy this site.
    if self.url.starts_with? "www."
      self.url = self.url[4..-1]
    end
    
    $s3 ||= AWS::S3.new()
  end
  
  def upload
    
    return if filename.end_with? "Icon\r"
    return if filename.include? "\r"
    
    # HTML files go straight in, assets go into a deploy slug container.      
    # Favicon goes to both places, in case somebody wants /favicon.ico
    
    slug_path = "#{@url}/#{deploy_slug}/#{filename}"
    old_slug_path = "#{@url}/#{previous_slug}/#{filename}"
    root_path = "#{@url}/#{filename}"
    
    if filename.end_with?("favicon.ico")
      root_path = "#{@url}/favicon.ico"
      upload_file(root_path)
      upload_file(slug_path)
    else
      if filename.end_with?(".html") or filename.end_with?(".htm")
        upload_file(root_path)
      elsif filename.end_with?(".css")
        upload_file(slug_path)
      else
        file_changed ? upload_file(slug_path) : move_file(old_slug_path, slug_path)
      end
    end
  end
  
  def upload_file(bucket_path)
    gzip =  filename.end_with?(".js") || filename.end_with?(".css")
    
    S3FileUploader.new().upload(local_file_path, bucket_path, gzip)
  end

  def move_file(source_bucket_path, target_bucket_path)
    S3FileMover.new().move(source_bucket_path, target_bucket_path, local_file_path)
  end
  
  def un_deploy
    
    # Important: Don't delete everything.
    return if !url || !deploy_slug
    
    bucket_path = [url, deploy_slug].join('/')

    return unless bucket_path
    $s3.buckets[ENV['AWS_BUCKET']].objects.with_prefix(bucket_path).delete_all
    $s3.buckets[ENV['AWS_BUCKET']].objects[bucket_path].delete
  end
  
  def destroy_site
    return unless @url
    $s3.buckets[ENV['AWS_BUCKET']].objects.with_prefix(@url).delete_all
    $s3.buckets[ENV['AWS_BUCKET']].objects[@url].delete
  end
  
end