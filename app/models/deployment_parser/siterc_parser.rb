class DeploymentParser::SitercParser < DeploymentParser

  def parse
    ConsoleLogger.ok '[siterc parser] tryring to locate site configuration file...'

    files(with_hidden: true).each do |filename|
      fname = relative_path_for_file(filename)

      if is_config?(fname)
        ConsoleLogger.ok "[siterc parser] config file found #{fname}"

        config_file = read_file(filename)
        @version.update_column('siterc', config_file)
      end
    end
  end

  def supported_config_formats
    %w[ .forgerc forgerc forgerc.txt forgerc.cfg ]
  end

  def is_config? f
    supported_config_formats.include?(f.to_s.strip)
  end

end
