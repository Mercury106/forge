class DeploymentParser::LinkParser < DeploymentParser

  def parse()
    find_and_replace()
  end

private

  def find_and_replace
    files.each do |filename|
      next unless filename.end_with? ".html" or filename.end_with? ".htm"
      text = read(filename)
      # text = make_relative_links_absolute(text, filename)
      text = parse_text(text, filename)
      write(filename, text)
    end
  end

  def make_relative_links_absolute(text, file)
    ConsoleLogger.ok('[link parser] making ralative links absolute')
    path_to_root = relative_path(file, @local_directory)

    if path_to_root == "."
      path_to_root = ""
    end

    text = text.gsub("href='/", "href='#{path_to_root}/")
    text = text.gsub('href="/', "href=\"#{path_to_root}/")

    text
  end

  def parse_text(text, file)

    files.each do |html_file_path|

      if html_file_path.end_with? '/index.html'

        # This is the directory the other file is in.
        # For example, pages/help/index.html is in pages/help
        directory_name = html_file_path.split("/")[0..-2].join('/')

        # This results in a . path. We don't replace those!
        next if @local_directory == directory_name

        # if pages/help.html exists, we'll want to link to that instead.
        alternative_html_file = "#{directory_name}.html"
        alternative_html_file_exists = detect_file(alternative_html_file)

        if !alternative_html_file_exists
          pattern = File.dirname(relative_path(file, html_file_path))
          replacement = relative_path(directory_name, directory_name+"/index.html")
        else
          pattern = relative_path(file, html_file_path)
          replacement = relative_path(file, alternative_html_file)
        end

        text = replace_link(text, pattern, replacement)


        if !alternative_html_file_exists

          absolute_path = "/"+relative_path(@local_directory, directory_name)
          replacement = "/"+relative_path(@local_directory, directory_name+"/index.html")
          text = replace_link(text, absolute_path, replacement)
        end

      end
    end

    return text
  end

  def detect_file(filename)
    @cached_results ||= {}
    if @cached_results[filename] != nil
      return @cached_results[filename]
    end
    @cached_results[filename] = files.include?(filename)
  end

  def replace_link(text, path, replacement_path)

    ['"', "'"].each do |quote|

      # Relative
      pattern = "href=#{quote}#{path}#{quote}"
      replacement_pattern = "href=#{quote}#{replacement_path}#{quote}"
      text = text.gsub(pattern, replacement_pattern)

      # Absolute
      pattern = "href=#{quote}/#{path}#{quote}"
      replacement_pattern = "href=#{quote}/#{replacement_path}#{quote}"
      text = text.gsub(pattern, replacement_pattern)
    end

    text
  end

end