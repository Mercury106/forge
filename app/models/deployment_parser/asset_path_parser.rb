class DeploymentParser::AssetPathParser < DeploymentParser

  def parse
    unless @assets_location_root
      ConsoleLogger.fail('[asset path parser] Asset location root wasn\'t set!')
      raise "Asset location root wasn't set!"
    end
    replace_asset_filenames
  end

  def set_assets_location_root(root)
    @assets_location_root = root
    ConsoleLogger.ok('[asset path parser] setting location root')
  end

private

  def replace_asset_filenames
    # files_to_parse = css_filenames + html_filenames
    ConsoleLogger.ok('[asset path parser] replacing html filenames')
    html_filenames.each do |filename|
      text = read(filename)

      # This is our pointer while we go through.
      working_path = Pathname.new(File.dirname(filename))

      # Replace relative URLs for assets with their CDN counterparts
      asset_filenames.each do |asset_filename|
        text = parse_asset_filename(asset_filename, text, working_path)
      end

      write(filename, text)
    end

    ConsoleLogger.ok('[asset path parser] replacing css filenames')

    css_filenames.each do |filename|
      text = read(filename)

      # This is our pointer while we go through.
      working_path = Pathname.new(File.dirname(filename))

      # Replace relative URLs for assets with their CDN counterparts
      asset_filenames.each do |asset_filename|
        text = parse_asset_filename(asset_filename, text, working_path)
      end

      write(filename, text)
    end


  end

  def replace_paths(text, absolute_path, relative_path, public_path)
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
    text
  end

  def parse_asset_filename(asset_filename, text, working_path)
    asset_filename = asset_filename.split("?")[0]
    asset_filename_path = Pathname.new(asset_filename)

    # This is the relative filename, from the current HTML file to the asset.
    # ../css/style.css
    relative_path = asset_filename_path.relative_path_from(working_path).cleanpath

    # This is the absolute URL for the asset in question.
    # /css/style.css
    absolute_path = "/" + relative_path_for_file(asset_filename_path).to_s

    # # If it's not the same as this file...
    public_path       = "#{@assets_location_root}#{absolute_path}"

    text = replace_paths(text, absolute_path, relative_path, public_path)
  end

  def html_filenames
    files.select {|file| file != "" && (file.end_with?(".html") || file.end_with?(".htm"))}
  end

  def css_filenames
    files.select {|file| file != "" && file.end_with?(".css")}
  end

  def asset_filenames
    files.select {|file| file != "" && !file.end_with?(".html") && !file.end_with?(".htm")}
  end

end