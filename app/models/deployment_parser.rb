# A deployment parser takes a local directory as argument!
class DeploymentParser

  def initialize(local_directory, version = nil)
    @local_directory = local_directory
    @version = version
  end

  def log(message, status = 'ok')
    parcel = {version_id: @version.id, message: message, status: status, time: "[#{Time.now.strftime("%H:%M:%S")}]", done: false}
    Site::Sockets.log_by_id(@version.site_id, JSON.generate(parcel)) if @version
  end

  # An enumerator for files in this folder
  def files(with_hidden: false)

    # Dir.glob will not match dotfiles unless
    # the flag is provided
    additional_args = []

    if with_hidden
      additional_args << File::FNM_DOTMATCH
    end

    Dir.glob(File.join(@local_directory, "**/*"), *additional_args).select {|filename|
      !File.directory?(filename)
    }
  end

  def process
    before_parse()
    parse()
    after_parse()
  end

  def before_parse
  end

  def after_parse
  end

  def relative_path(first_path, last_path)
    first_path = File.dirname(relative_path_for_file(first_path))
    last_path = relative_path_for_file(last_path)
    Pathname.new(last_path).relative_path_from(Pathname.new(first_path)).to_s
  end

private

  # Returns a Pathname
  def relative_path_for_file(absolute_path)
    here      = Pathname.new(@local_directory)
    file_path = Pathname.new(absolute_path).relative_path_from(here)
    return file_path
  end

  def write(filename, text)
    File.open(filename, 'w') { |file| file.write(text) }
  end

  def read_file(filename)
    File.open(filename).read
  end

  def read(filename)
    File.open(filename).read
  end

  def add_file(filename, contents)
    final_filename = File.join(@local_directory, filename)
    write(final_filename, contents)
  end
end
