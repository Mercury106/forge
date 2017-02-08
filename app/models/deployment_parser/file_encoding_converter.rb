require 'charlock_holmes'
class DeploymentParser::FileEncodingConverter < DeploymentParser
  def parse
    ConsoleLogger.ok('[encoding converter] force utf-8 encoding')
    html_files.each do |filename|
      contents = read(filename)
      detection = CharlockHolmes::EncodingDetector.detect(contents)
      encoding = detection[:encoding] || 'utf-8'
      next if encoding.downcase == 'utf-8'
      encoded = contents.force_encoding(encoding).encode('utf-8')
      write(
        filename,
        encoded.sub(/<meta [^>]+charset[^>]+>/, '<meta charset="utf-8">')
      )
    end
  end

  private

  def html_files
    files.select do |filename|
      filename.end_with?('.html') || filename.end_with?('.htm')
    end
  end
end 