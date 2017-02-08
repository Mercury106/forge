desc "Runs cron maintenance tasks."
task :cron => :environment do
  puts "Running cron at #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}..."
  
  LogParser.new.parse_all()
  Rake::Task["session:prune"].execute
end

desc "Update all invoices"
task :bill => :environment do
  User.all.each do |user|
    user.sites.each do |site|
      site.bill_unbilled_usage()
    end
  end
end


task :sync => :environment do
  User.all.each do |user|
    if user.stripe_card_token
      customer = user.stripe_customer
      if customer.discount.coupon.percent_off
        user.discount = customer.discount.coupon.percent_off.to_f / 100
        user.save()
      end
    end
  end
end

namespace :session do
  desc "Prune old session data"
  task :prune => :environment do
    ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", 2.weeks.ago])
  end
end
