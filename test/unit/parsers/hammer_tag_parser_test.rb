require 'test_helper'
require "fileutils"

class HammerTagParserTest < ActiveSupport::TestCase
  context "A Hammer Tag Parser" do
    setup do
      @tmpdir = Dir.mktmpdir
      @index_path = File.join(@tmpdir, 'index.html')
      File.open(@index_path, 'w') do |file|
        file.write("a<!-- Hammer reload -->TESTING<!-- /Hammer reload -->b")
      end
      @parser = DeploymentParser::HammerTagParser.new(@tmpdir)
      @parser.parse
    end

    teardown do
      FileUtils.remove_entry_secure @tmpdir
    end

    should "clear out Hammer tags" do
      assert_equal 'ab', File.read(@index_path)
    end
  end  
  
  context "A Hammer Tag Parser" do
    setup do
      @tmpdir = Dir.mktmpdir
      @index_path = File.join(@tmpdir, 'index.html')
      File.open(@index_path, 'w') do |file|
        file.write("this is an example")
      end
      @parser = DeploymentParser::HammerTagParser.new(@tmpdir)
      @parser.parse
    end

    teardown do
      FileUtils.remove_entry_secure @tmpdir
    end

    should "clear out Hammer tags" do
      assert_equal 'this is an example', File.read(@index_path)
    end
  end
end
