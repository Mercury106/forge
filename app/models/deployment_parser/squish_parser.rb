require "turbojs/package"

class DeploymentParser::SquishParser < DeploymentParser

  def parse()
    add_squish_file()
    add_squish_tags_to_all_html_files()
  end

private

  # Creating a squish file and adding it to the project

  def add_squish_file
    ConsoleLogger.ok('[squish parser] adding squish file')
    contents = generate_squish_hash
    squish_text = compile(contents.to_json)
    add_file("_squish.js", squish_text)
  end

  def generate_squish_hash
    ConsoleLogger.ok('[squish parser] generatin squish hash')
    pages = {}
    files.each do |file|
      next unless file.end_with? ".html"
      pages["/"+relative_path_for_file(file).to_s] = {html: read(file)}
    end

    return pages
  end

  def compile(contents)
    %Q(
      /* TurboJS v1.0 */;
      TurboJS.cache = #{contents};
      TurboJS.run();
    )
  end

  # Extracting HTML contents

  def extract_title_from_text(text)
    ConsoleLogger.ok('[squish parser] extracting HTML contents')
    title = text.match(/<title>(.*)<\/title>/m).to_s
    title.gsub!("<title>", "")
    title.gsub!("</title>", "")
    title = HTMLEntities.new.decode(title)
    return title.to_s
  end

  def extract_body_from_text(text)
    text = text.encode!('UTF-8', 'UTF-8', :invalid => :replace)
    text = text.match(/<body(.*)<\/body>/m).to_s.gsub("<body>", "").gsub("</body>", "").to_s
    text = text.gsub(/<script>window.jQuery \|\| document.write(.*)<\/script>/, "")
  end

  # Adding squish tags to HTML files

  def add_squish_tags_to_all_html_files()
    ConsoleLogger.ok('[squish parser] adding squish tags to HTML files')
    files.each do |file|
      next unless file.end_with? ".html"
      text = add_squish_to_text(read(file), file)
      write(file, text)
    end
  end

  def add_squish_to_text(text, filename)
    file_path   = relative_path_for_file(File.dirname(filename))
    squish_path = Pathname.new('_squish.js').relative_path_from(file_path)
    tag = %Q(
      <script>
        (function(t,u,r,b,o,s){
          o=document.createElement(u);
          o.setAttribute('data-turbojs', b);
          o.async=1;o.src=r;
          s=t.getElementsByTagName(u)[0];
          s.parentNode.insertBefore(o, null);
        })(document, 'script',
          "//#{ENV['CDN_SITE_ASSET_HOST'] || 'dooe3vx785zy.cloudfront.net'}/assets/turbojs/#{ENV['TURBOJS_VERSION']}/turbo.js?version=#{ENV['TURBOJS_VERSION']}",
          '#{squish_path}');
      </script>
    )

    text = text.gsub("</head>", "#{tag}</head>")
    return text
  end

end