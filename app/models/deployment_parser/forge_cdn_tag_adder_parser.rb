class DeploymentParser::ForgeCdnTagAdderParser < DeploymentParser

  def set_slug slug
    @slug = slug
  end

  def parse
    ConsoleLogger.ok('[CDN tag adder] adding forge token')
    files.each do |filename|
      puts filename
      next unless filename.end_with? "index.html"
      text = read(filename)
      text = replace_tags(text, @slug)

      if text
        write(filename, text)
      end
    end
  end

private

  def replace_tags text, slug
    text = text.gsub("</body>", "<meta name='forge-tag' value='forge-token:#{slug}' /></body>")
    text
  end

end