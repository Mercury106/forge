class S3FileMover
  def move(source_bucket_path, target_bucket_path, local_file_path)
    $s3 ||= AWS::S3.new()
    @source = source_bucket_path.split("?")[0]
    @target = target_bucket_path.split("?")[0]

    begin
      $s3.buckets[ENV['AWS_BUCKET']].objects[@source].move_to(@target, acl: :public_read)
    rescue Exception => e
      gzip =  @source.end_with?(".js") || @source.end_with?(".css")
      S3FileUploader.new().upload(local_file_path, target_bucket_path, gzip)
    end
  end
end