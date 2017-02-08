class LogParser

  # A Cloudfront log parser. Works a treat.

  # Fields: date time x-edge-location sc-bytes c-ip cs-method cs(Host) cs-uri-stem sc-status cs(Referer) cs(User-Agent) cs-uri-query cs(Cookie) x-edge-result-type x-edge-request-id
  # ["2013-01-20", "21:01:31", "FRA6", "442", "87.194.167.21", "GET", "dc4941bvk7ydh.cloudfront.net", "/test1.hammr.co/images/autobots.png", "304", "http://test1.hammr.co/", "Mozilla/5.0%20(Macintosh;%20Intel%20Mac%20OS%20X%2010_8_2)%20AppleWebKit/536.26.17%20(KHTML,%20like%20Gecko)%20Version/6.0.2%20Safari/536.26.17", "-", "-", "Hit", "iBNlT2eQiqEAH7jljTXo7YRrjS5DahndOJOUr7VwlyvL78L9-2Za7g==\n"]

  require 'rubygems'
  require 'zlib'
  require 'aws/s3'
  require 'tempfile'
  
  def urls
    s3_objects.collect {|object| object.url_for(:read)}
  end
  
  def s3_objects
    s3 = AWS::S3.new()
    bucket = ENV['LOG_BUCKET']
    s3.buckets[bucket].objects.to_a
  end

  def parse_all
    s3_objects.each do |object|
      url = object.url_for(:read)
      
      file = Tempfile.new('cloudfront-line')
      file.binmode
      
      chunk_size = 5_242_880 # (5MB) size of each chunk to request in bytes
      obj = object # AWS::S3.new.buckets[bucket_name].objects[object_key]
      size = obj.content_length
      byte_offset = 0
       
      File.open(file, 'wb') do |file|
        while byte_offset < size
          range = "bytes=#{byte_offset}-#{byte_offset + chunk_size - 1}"
          file.write(obj.read(:range => range))
          byte_offset += chunk_size
        end
      end

      file.rewind
      
      begin
        Zlib::GzipReader.new(file).each_line {|line| parse_cloudfront_line(line)}
      rescue => e
        puts "Error gzipping: #{e}"
        puts "File: #{file}"
        puts "Object: #{object}"
        puts "object url: #{object.url_for(:read)}"
        next
      end
      
      puts " - lines parsed: #{file.lines.count}"
      object.delete if Rails.env.production?
    end
  end
   
  def parse_cloudfront_line(line)
    
    return if line.strip.match(/^#/)
    
    date, time, _, bytes, _, _, _, url = line.split("\t")

    date = Time.parse(date + " " + time)
    # hour = time.hour
    # date = Date.parse(date)
    host     = url.split("/")[1]
    filename = url.split("/")[2..-1].join("/")

    if filename.strip != "-"
      # puts " - adding #{bytes} usage to #{host} for #{filename}."
      add_usage(host, bytes, date)
    end
  rescue => e
    puts "Rescue from line: #{line}: #{e} (#{e.backtrace})"
  end
  
  def add_usage(host, bytes, date)
    site = Site.find_by_url(host)
    if site
      site.add_usage(bytes, date)
    end
  end

end