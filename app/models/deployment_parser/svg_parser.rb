class DeploymentParser::SvgParser < DeploymentParser

  def parse
    ConsoleLogger.ok('[svg parser] replacing path tags')
    files.each do |filename|
      if File.extname(filename) == ".svg"
        text = read(filename)
        text = replace_path_tags(text, filename)
        write(filename, text)
      end
    end
  end

  def set_url(url)
    @url = url
  end

private


  def replace_path_tags(text, filename)
    working_path = Pathname.new(File.dirname(filename))

    html_filenames.each do |filename|

      file_path = Pathname.new(filename)

      relative_path = file_path.relative_path_from(working_path).cleanpath
      absolute_path = "/" + relative_path_for_file(file_path).to_s

      public_path   = ["http://", @url, absolute_path].join()

      ['"', "'", "("].each do |quote|

        find = [
          [quote, relative_path].join(),
          [quote, absolute_path].join(),
          [quote, "./", relative_path].join(),
        ]
        replace = [quote, public_path].join()
        find.each do |find|
          text = text.gsub(find, replace)
        end
      end
    end

    return text
  end

  def html_filenames
    files - asset_filenames
  end

  def asset_filenames
    files.select {|file| file != "" && !file.end_with?(".html")}
  end

end