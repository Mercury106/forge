class DeploymentParser::JavascriptParser < DeploymentParser

  def parse
    ConsoleLogger.ok('[javascript parser] parsing javascripts')
    files.each do |filename|
      next unless filename.end_with?(".html") or filename.end_with?(".js")
      text = read(filename)
      text = parse_text(text)
      write(filename, text)
    end
  end

  def parse_text(text)
    begin
      text = text.gsub("$(window).load(", "$(window).ready(")
    rescue
    end
    text
  end

end