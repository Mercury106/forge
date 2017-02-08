# require "test_helper"
# require "fileutils"

# class VersionDeployerTest < Test::Unit::TestCase
  
#   context "A version deployer" do
#     setup do
#       @deployer = VersionDeployer.new
#       @deployer.url = "example.com"
#       @deployer.deploy_slug = "deploy-slug-123"
#       @deployer.site = Site.new
#     end
    
#     context "with a zipfile of files" do
#       should "find a root path for OSX zipfiles" do
#         @deployer.expects(:zipfile_filenames).returns(['__MACOSX/', 'elliott/'])
#         assert_equal "elliott/", @deployer.send(:root_path)
#       end
      
#       should "not find a nonroot path for OSX zipfiles" do
#         @deployer.expects(:zipfile_filenames).returns(['assets/', 'images/'])
#         assert_equal nil, @deployer.send(:root_path)
#       end

#       should "give the correct filenames when there's a root path" do
#         @deployer.expects(:zipfile_filenames).at_least_once.returns(['__MACOSX/', 'elliott/', 'elliott/index.html'])
#         assert_equal "elliott/", @deployer.send(:root_path)
#         assert_equal ['index.html'], @deployer.send(:filenames)
#         assert_equal ['index.html'], @deployer.send(:html_filenames)
#       end
#     end
    
#     context "when deploying" do
#       should "not upload .scss files" do
#         skip 'not upload .scss files'
#       end
#     end
    
#     context "with a zip file" do
#       setup do
#         zipfile_path = File.join(Rails.root, 'test', '1.zip')
#         @deployer.file = File.open(zipfile_path)
#       end
      
#       should "Be able to find the filenames in the zipfile wihtout the root path" do
#         assert_equal "Build/", @deployer.send(:root_path)
#         assert @deployer.send(:filenames).include? "index.html"
#       end
      
#       should "write out to a directory" do
#         path = File.join(Rails.root, "tmp", "_test_zipfile")
#         FileUtils.rm_rf path
#         @deployer.version = Version.new
#         @deployer.local_directory = path
        
#         VCR.use_cassette('deploying', :record => :new_episodes) do
#           @deployer.deploy()
#         end
#       end
#     end
#   end
# end
