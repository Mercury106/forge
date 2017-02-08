class Version < ActiveRecord::Base
  module GithubDeployer
    extend ActiveSupport::Concern

    module ClassMethods
      def import_from_github_without_delay(id)
        version = Version.find(id)
        version.import_from_github_without_delay()
      end
    end

    def github_directory
      @github_directory ||= Dir.mktmpdir
    end

    def import_from_github_without_delay
      return false unless site.github_path
      self.update_attributes :percent_deployed => 1
      download_from_github()
    end

    def import_from_github
      ImportFromGithubWorker.perform_async(id) if site.github_path.present?
    end

  private

    def download_from_github
      require 'net/http'

      # req = Net::HTTP::Get.new("/repos/#{site.github_path}/zipball?access_token=#{site.user.github_token}")
      # http = Net::HTTP.new("api.github.com", 443)
      # http.use_ssl = true
      # resp = http.request(req)

      # temporary_directory = Dir.mktmpdir

      repo_path = site.github_path.split("/")[0..1].join("/")
      directory_path = site.github_path.split("/")[2..-1].join("/")

      url = "https://api.github.com/repos/#{repo_path}/zipball?access_token=#{site.user.github_token}"

      if site.github_branch
        url += "&ref=#{site.github_branch}"
      end

      response = Net::HTTP.get_response(URI.parse(url))

      if response['location']

        url = response['location']
        # response = Net::HTTP.get_response(URI.parse(url))

        zipfile = Zip::File.open(open(url))

        tmpdir = Dir.mktmpdir
        zipfile_name = File.join(tmpdir, 'zip.zip')
        new_zipfile = Zip::File.open(zipfile_name, Zip::File::CREATE)

        zipfile.each { |entry|
          name = entry.name
          name = name.split("/")[1..-1].join("/")
          match = name.start_with? directory_path

          if match

            repo_folder = entry.name.split("/")[0]
            new_name = entry.name[repo_folder.length..-1]
            new_name = new_name[directory_path.length+1..-1]
            new_name = new_name[1..-1] if new_name[0] == "/"

            local_filename = File.join(tmpdir, new_name)
            FileUtils.mkdir_p(File.dirname(local_filename))
            next if local_filename.end_with? "/"

            file = entry.extract(local_filename)
            new_zipfile.add(new_name, File.open(local_filename))
          end
        }
        new_zipfile.close()

        puts zipfile_name

        self.upload = File.open(zipfile_name)
        self.save
        # self.deploy()

        FileUtils.rm_rf(tmpdir)
      end

    end

    def exclude_file?(filename)
      return true if filename =~ /\.git/
      return true if filename =~ /\.DS_Store/
      return true if filename =~ /\.sass-cache/

      false
    end
    
  end
end