desc "Re-deploy all sites."
namespace :sites do
  task :deploy_all => :environment do
    puts "Deploying all sites..."
    Site.all.each do |site|
      if site.current_version
        puts "Deploying #{site.url}"
        site.current_version.deploy()
      end
    end
  end
  
  desc "Deploy a site"
  task :deploy, [:url] => :environment do |t, args|
    if args.url
      site = Site.find_by_url(args.url)
      if site
        current_version = site.current_version
        if current_version
          puts "Deploying version ##{current_version.id}"
          current_version.deploy()
        end
      end
    end
  end
end