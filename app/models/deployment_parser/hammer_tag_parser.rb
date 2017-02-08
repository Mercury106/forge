# Hammer tag parser. For parsing out Hammer tags.
class DeploymentParser::HammerTagParser < DeploymentParser
  def parse
    ConsoleLogger.ok('[hammer tag parser] parsing special hammer tags')
    files.each do |filename|
      next unless filename.end_with? ".html"
      text = read(filename)
      text = parse_text(text)
      write(filename, text)
    end
  end

  def regex
    Regexp.new("<!-- Hammer reload -->(.*)<!-- \/Hammer reload -->".force_encoding("UTF-8"), Regexp::MULTILINE)
  end

  def parse_text(text)
    text.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    text.gsub! self.regex, ""
    text
  end
end