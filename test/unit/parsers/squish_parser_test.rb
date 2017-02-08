require 'test_helper'

class SquishParserTest < ActiveSupport::TestCase

  context "A Squish parser" do
    setup do
      @parser = DeploymentParser::SquishParser.new("/tmp")
    end
    
    context "when parsing a set of files" do
      
      setup do
        @parser.expects(:files).at_least_once.returns ['/tmp/index.html', '/tmp/about.html']
      end
      
      should "add a squish file" do
        
        text = "<html><body>Testing</body></html>"
        @parser.expects(:add_file).with('_squish.js').with() {|filename, contents| 
          filename == "_squish.js" && contents.include?("Testing")
        }
        @parser.expects(:read).with('/tmp/index.html').returns(text).at_least_once
        @parser.expects(:read).with('/tmp/about.html').returns(text).at_least_once
        @parser.parse()
        
      end
      
    end    
  end
end
