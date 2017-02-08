class DeploymentParser::BodyScriptParser < DeploymentParser
  
  def parse
    files.each do |filename|
      next unless filename.end_with? ".html"
      text = read(filename)
      text = replace_body_scripts(text)

      if text
        write(filename, text)
      end
    end
  end

private

  def replace_body_scripts(text)

    # If we're dealing with a silly HTML file, then let's not do so much.
    if !text.include? "</head>"
      return text
    end

    # Bring it into a Nokogiri parser
    doc = Nokogiri.parse(text)

    # Find the HEAD element first...
    head = doc.search('head').first

    # Move all body scripts into the head for justice
    doc.search('body script').each do |script|
      script.remove()
      head.add_child(script)
    end

    # We want the inner_html, not the Nokogiri object.
    # Otherwise it reformats and adds DOCTYPE and things.
    return doc.inner_html

  rescue => e
    
    logger.debug "Error in BodyScriptParser: #{e}"
    return false
  end
  
end