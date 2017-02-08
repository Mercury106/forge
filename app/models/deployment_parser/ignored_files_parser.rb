class DeploymentParser::IgnoredFilesParser < DeploymentParser

  def parse
    delete_files
  end

private

  def delete_files
    ConsoleLogger.ok('[ignored files parser] deleting files')
    files.each do |file|
      if File.extname(file) == '.scssc'
        FileUtils.rm(file)
      end
    end
  end

end