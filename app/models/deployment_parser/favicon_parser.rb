class DeploymentParser::FaviconParser < DeploymentParser
  
  def parse
    replace_broken_favicons
  end

private

  def replace_broken_favicons
    files.each do |filename|
      next unless filename.end_with? ".ico"

      require "digest"
      require "fileutils"
      hash = Digest::MD5.hexdigest(File.read(filename))

      if hash == "449ffe6f8e44e9e4d3feb300cfe03fe9"
        replacement_favicon = File.join(Rails.root, 'fixtures', 'favicon.ico')
        FileUtils.cp(replacement_favicon, favicon)
      end
    end
  end

end