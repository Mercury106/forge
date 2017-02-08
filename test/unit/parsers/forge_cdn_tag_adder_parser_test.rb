class ForgeCDNTagAdderParserTest < ActiveSupport::TestCase
  
  context "a deployment parser" do
    
    setup do
      # @dir = Dir.mktmpdir("build-testing")
      # @parser = DeploymentParser.new(@dir)
    end
    
    should "calculate relative paths" do
      # assert_equal "../index.html", @parser.relative_path("/test/index.html", "/index.html")
      # assert_equal "index.html", @parser.relative_path("/test/index.html", "/test/index.html")
      # assert_equal "index.html", @parser.relative_path("/test/index.html", "/test/index.html")
    end
    
  end
  
end