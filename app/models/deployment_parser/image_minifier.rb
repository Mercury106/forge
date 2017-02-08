class DeploymentParser::ImageMinifier < DeploymentParser
  def parse
    files.each do |filename|
      if filename.end_with? ".png"
        pngquant_path = File.join(Rails.root, "bin", "pngquant-#{Rails.env.to_s}")

        if File.exist? "#{pngquant_path}.local"
          pngquant_path = File.join(Rails.root, "bin", "pngquant-#{Rails.env.to_s}.local")
        end

        `#{pngquant_path} -f --ext .png '#{filename}'`
      end
    end
  end
end