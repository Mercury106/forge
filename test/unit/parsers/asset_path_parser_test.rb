require 'test_helper'
require 'fileutils'

class AssetPathParserTest < ActiveSupport::TestCase

  context "An Asset Path Parser" do
    setup do
      @tmpdir = Dir.mktmpdir

      FileUtils.mkdir File.join(@tmpdir, 'images')
      FileUtils.touch File.join(@tmpdir, 'images/logo.png')

      @parser = DeploymentParser::AssetPathParser.new(@tmpdir)
      @parser.set_assets_location_root "cloudfront.net"
    end

    teardown do
      FileUtils.remove_entry_secure @tmpdir
    end
    
    ['"', "'"].each do |quote_style|
      ['index.html', 'blog/index.html'].each do |filename|
        context "inside #{filename} with #{quote_style} quotes" do
            
          setup do
            @index_path = File.join(@tmpdir, filename)
            FileUtils.mkdir_p File.dirname(@index_path)
          end
          
          context 'with url() paths' do
            should 'rewrite image path' do
              File.open(@index_path, 'w') do |file|
                file.write("<img style='background: url(/images/logo.png)' />")
              end
              @parser.parse
              expected = "<img style='background: url(cloudfront.net/images/logo.png)' />"
              assert_equal expected, File.read(@index_path)
            end

            # should "rewrite image path with query string" do
            #   File.open(@index_path, 'w') do |file|
            #     file.write("<img style='background: url(/images/logo.png?a=1)' />")
            #   end
            #   @parser.parse
            #   expected = "<img style='background: url(cloudfront.net/images/logo.png)' />"
            #   assert_equal expected, File.read(@index_path)
            # end
          end
          
          context 'with absolute paths' do
            setup do
              File.open(@index_path, 'w') do |file|
                file.write("<img src=#{quote_style}/images/logo.png#{quote_style} />")
              end
              @parser.parse
            end

            should 'rewrite image path' do
              expected = "<img src=#{quote_style}cloudfront.net/images/logo.png#{quote_style} />"
              assert_equal expected, File.read(@index_path)
            end
            
          end

          context 'with relative paths' do
            setup do
              
              pathname = Pathname.new("images/logo.png").relative_path_from Pathname.new(File.dirname(filename))
              File.open(@index_path, 'w') do |file|
                file.write("<img src=#{quote_style}#{pathname}#{quote_style} />")
              end
              @parser.parse
            end

            should 'rewrite image path' do
              expected = "<img src=#{quote_style}cloudfront.net/images/logo.png#{quote_style} />"
              assert_equal expected, File.read(@index_path)
            end
          end
          
        end
      end
    end
  end
end
