class S3FileUploader

  def upload(local_file_path, bucket_path, gzip)
    @s3 = AWS::S3.new()
    @bucket_path = bucket_path.split("?")[0]
    @local_file_path = local_file_path
    @filetype = MIME::Types.of(@local_file_path).join(', ')

    if gzip
      upload_gzipped
    else
      upload_not_gzipped
    end
  end

private

  # def delete_existing_object
  #   @s3.buckets[ENV['AWS_BUCKET']].objects[bucket_path].delete
  # end

  def upload_not_gzipped
    @s3.buckets[ENV['AWS_BUCKET']].objects[@bucket_path].write({
      :file => @local_file_path, 
      :acl => :public_read,
      :cache_control => "max-age=2592000, public",
      :content_type => @filetype
    })
  end

  def upload_gzipped
    str = StringIO.new()
    gz = Zlib::GzipWriter.new(str)
    gz.write File.read(@local_file_path)
    gz.close

    obj = @s3.buckets[ENV['AWS_BUCKET']].objects[@bucket_path]
    obj.write(str.string, {
      :acl => :public_read,
      :content_encoding => 'gzip',
      :cache_control => "max-age=2592000, public",
      :content_type => @filetype
    })
  end

end