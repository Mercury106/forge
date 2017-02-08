# encoding: utf-8

module Paperclip
  class Unzipper < Processor
    
    class InstanceNotGiven < ArgumentError; end
      
    def initialize(file, options = {}, attachment = nil)
      super
      @file = file
      @attachment = attachment
      @instance = attachment.instance
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
    end
    
    def make

      require 'fileutils'
      require 'zip/filesystem'
      require 'open-uri'

      s3 = AWS::S3.new

      # Seed
      # TODO: Better numbers.
      num = @instance.url_slug
      version = @instance.version.to_s
      filename_array = []

      # tmp/0984029834/index.html is where we stash them
      output_path = File.join(Rails.root, "tmp", num, version)
      
      FileUtils.mkdir_p output_path

      # file = open(zipfile.url)
      file = File.open(@file.path)
      
      Zip::File.open(file) do |zipped_file|
        zipped_file.each do |file|
          
          file_path = File.join(output_path, file.name)
          FileUtils.mkdir_p File.dirname(file_path)
          
          next if file.name.ends_with? "/"
          
          zipped_file.extract(file, file_path)

          # if file_path.ends_with? ".html"
          #   # .force_encoding("ISO-8859-1")
          #   contents = IO.read(file_path).encode("utf-8", replace: nil)
          #   contents = contents.gsub "ws.onopen = function(){ws.onclose = function(){document.location.reload()}}", ""
          #   File.open(file_path, "w") {|file| file.puts contents}
          # end
          
          @instance.add_file(file, file_path)
          
          bucket_path = num + '/' + version + '/' + file.name

          filetype = MIME::Types.of(file_path).join(', ')

          S3_CONFIG = YAML.load_file("#{::Rails.root}/config/s3.yml")[Rails.env]
          s3.buckets[S3_CONFIG['bucket']].objects[bucket_path].write(:file => file_path, :acl => :public_read, :content_type => filetype)

        end
      end
      
      return @file
    end
    
  end
end
