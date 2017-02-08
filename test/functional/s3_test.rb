class TestS3 < ActiveSupport::TestCase

  class Zipper
    def self.zip(dir, zip_dir)

      dir.sub!(%r[/$],'')
      archive = zip_dir
      FileUtils.rm archive, :force=>true

      Zip::File.open(archive, 'w') do |zipfile|
        Dir["#{dir}/**/**"].reject{|f|f==archive}.each do |file|
          zipfile.add(file.sub(dir + '/' ,''),file)
        end
      end
    end
  end

  def site_from_directory(directory, url)
    zipfile          = File.join(Dir.mktmpdir, 'zip.zip')
    Zipper.zip directory, zipfile
    site = FactoryGirl.create(:site, :url => url)
    version = site.versions.create(:upload => File.open(zipfile))
    site.current_version = version
    site.save()
    site
  end

  def relative_path(from, to)
    Pathname.new(from).relative_path_from(Pathname.new(to))
  end

  context "Deleting a directory when a site is deleted" do
    setup do
      VCR.insert_cassette "creating-directory"
      test_case_directory = File.join(Rails.root, 'test', 'functional', 'parsers_tests')
      @test_cases = Dir.glob(File.join(test_case_directory, '*'))

      @output_directory = File.join @test_cases.last, 'output'
      @site = site_from_directory(@output_directory, "functional-site-deleting.#{ENV['EXTERNAL_CNAME']}")

      @url = @site.url

      @s3 = AWS::S3.new
    end

    teardown do
      VCR.eject_cassette
    end

    context "creating the directory" do
      setup do
        @site.save
      end

      should "create the folder in the bucket" do
        skip('Move s3 test to RSpec')
        assert @s3.buckets[ENV['AWS_BUCKET']].objects[@url+"/index.html"].exists?
      end
    end    

    context "when destroyed" do
      setup do
        @site.destroy()
      end

      should "destroy the folder in the bucket" do
        skip('Move s3 test to RSpec')
        assert_equal [], @s3.buckets[ENV['AWS_BUCKET']].objects.with_prefix(@url).to_a
      end
    end

    context "when destroyed" do
      setup do
        @output_directory = File.join @test_cases.last, 'output'
        @other_site = site_from_directory(@output_directory, "functional-site-deleting-should-still-be-here.#{ENV['EXTERNAL_CNAME']}")
        @site.destroy()
      end

      should "destroy the folder in the bucket" do
        skip('Move s3 test to RSpec')
        assert_not_equal [], @s3.buckets[ENV['AWS_BUCKET']].objects.with_prefix(@other_site.url).to_a
      end

      teardown do
        @other_site.destroy()
      end
    end
  end

  context "Deployment test cases" do

    setup do
      VCR.insert_cassette "deployment-testing"
      test_case_directory = File.join(Rails.root, 'test', 'functional', 'parsers_tests')
      @test_cases = Dir.glob(File.join(test_case_directory, '*'))

      # TODO: Make this a little nicer. This is what determines that stupid deploy slug.
      VersionDeployer.any_instance.stubs(:deploy_slug).returns('sample-deploy-slug')
    end

    teardown do
      VCR.eject_cassette
    end

    should "deploy the contents from all of our functional test sites to S3." do
      skip('Move s3 test to RSpec')
      @test_cases.each_with_index do |test_case_directory, i|
        output_directory = File.join test_case_directory, 'output'

        site = site_from_directory(output_directory, "functional-site-#{i}.#{ENV['EXTERNAL_CNAME']}")
        slug = site.version_deployer.deploy_slug

        files = Dir.glob(File.join(output_directory, "**/*"))
        s3 = AWS::S3.new()

        files.each do |local_file|
          next if File.directory? local_file

          file_path_relative_to_project_directory = relative_path(local_file, output_directory)

          # HTML files are directly in the folder. Assets are namespaced by the slug.
          # This is because assets are served from the CDN for max caching.
          should_be_deployed_to_the_cdn = File.extname(file_path_relative_to_project_directory) != '.html'

          if should_be_deployed_to_the_cdn
            s3_path = [site.url, slug, file_path_relative_to_project_directory].join('/')
          else
            s3_path = [site.url, file_path_relative_to_project_directory].join('/')
          end

          # Make sure the S3 object is the same as the local reference file
          s3_object = s3.buckets[ENV['AWS_BUCKET']].objects[s3_path]
          assert_equal s3_object.read(), File.open(local_file).read
        end
      end
    end
  end
end