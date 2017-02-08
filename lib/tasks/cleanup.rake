namespace :sites do
  # task :set_diffs => :environment do
  #   Site.all.each do |site|
  #     puts "Processing #{site.url} (##{site.id})"
  #     site.versions.limit(10).each do |version|
  #       next unless version.file_hash == {}
  #       begin
  #         VersionDeployer.new(:version => version).send :unzip
  #         puts version.scoped_id
  #         puts " - version #{version.scoped_id}"
  #       rescue
  #       end
  #     end

  #     site.versions.limit(10).each do |version|; version.set_diff_and_save_without_delay; end
  #   end
  # end

  task :delete_unused_directories => :environment do
  end

end