require 'test_helper'

class LogParserTest < ActiveSupport::TestCase
  
  context "A log parser" do
    setup do
      @parser = LogParser.new
    end
    
    should "parse a line" do
      line = ["2013-01-20", "21:01:31", "FRA6", "442", "87.194.167.21", "GET", "dc4941bvk7ydh.cloudfront.net", "/test1.hammr.co/images/autobots.png", "304", "http://test1.hammr.co/", "Mozilla/5.0%20(Macintosh;%20Intel%20Mac%20OS%20X%2010_8_2)%20AppleWebKit/536.26.17%20(KHTML,%20like%20Gecko)%20Version/6.0.2%20Safari/536.26.17", "-", "-", "Hit", "iBNlT2eQiqEAH7jljTXo7YRrjS5DahndOJOUr7VwlyvL78L9-2Za7g==\n"].join("\t")
      
      @parser.expects(:add_usage).with('test1.hammr.co', '442', Time.parse('2013-01-20 21:01:31')).returns(true)
      @parser.parse_cloudfront_line(line)
    end
  end
  
end
