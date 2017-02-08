require 'fileutils'
require 'test_helper'

class TestParsers < ActiveSupport::TestCase
  
  class << self
    def compare_directories a, b
      _compare_directories(a, b)
      _compare_directories(b, a)
    end

    def _compare_directories a, b
      a_files = Dir.glob(File.join(a, "**/*"))
      b_files = Dir.glob(File.join(b, "**/*"))
      
      a_files.each do |a_file_path|
        
        relative_file_path = Pathname.new(a_file_path).relative_path_from(Pathname.new(a))
        b_file_path = File.join(b, relative_file_path)
        
        raise "File missing: #{a_file_path} wasn't compiled to Build folder" unless File.exist?(b_file_path)
        
        if !File.directory? a_file_path    
          if !FileUtils.compare_file(b_file_path, a_file_path)
            raise %Q{
      Error in #{relative_file_path} (#{b_file_path} / #{a_file_path}):
      #{`diff #{a_file_path} #{b_file_path}`}}
          end
          
          print "."
        end
        
      end
    end
  end

  
  context "Functional test cases" do
    
    test_case_directory = File.join(Rails.root, 'test', 'functional', 'parsers_tests')
    test_case_directory_glob = File.join(Rails.root, 'test', 'functional', 'parsers_tests', '*')
    test_cases = Dir.glob(test_case_directory_glob)
    
    test_cases.each do |test_case_directory|
      context "Testing #{test_case_directory}" do
        
        input_directory = File.join test_case_directory, 'input'
        reference_directory = File.join test_case_directory, 'output'
        
        Dir.mktmpdir "project" do |temporary_directory|

          # Copy into here
          FileUtils.cp_r(Dir[test_case_directory+'/input/*'], temporary_directory)
          
          deployer = VersionDeployer.new(:local_directory => temporary_directory, :url => "example.com", :deploy_slug => "1390764048")
          deployer.parse()
          
          compare_directories(temporary_directory, reference_directory)
          
        end
      end
    end
  end
  
end
