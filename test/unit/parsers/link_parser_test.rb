require 'test_helper'
require "fileutils"

class LinkParserTest < ActiveSupport::TestCase
  context "A link parser" do
    setup do
      @tmpdir = Dir.mktmpdir
      @index_path = File.join(@tmpdir, 'index.html')
      @other_file_path = File.join(@tmpdir, 'pages/index.html')
      
      File.open(@index_path, 'w') do |file|
        file.write("<a href='pages'>This is my link</a>")
      end
      
      FileUtils.mkdir_p(File.dirname(@other_file_path))
      File.open(@other_file_path, 'w') do |file|
        file.write("The other file")
      end
      
      @parser = DeploymentParser::LinkParser.new(@tmpdir)
      @parser.parse()
    end

    teardown do
      FileUtils.remove_entry_secure @tmpdir
    end

    should "rewrite links" do
      assert_equal "<a href='pages/index.html'>This is my link</a>", File.read(@index_path)
    end
  end  

end
