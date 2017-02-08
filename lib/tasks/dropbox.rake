require 'dropbox_sdk'

desc "Get Dropbox ids for all users, who has oauth token"

namespace :dropbox do
  task :get_ids => :environment do
    puts 'Get Dropbox ids for all users, who has oauth token'
    User.select(:id, :dropbox_token)
        .where('dropbox_token IS NOT NULL ')
        .each do |user|
          begin
            dc = DropboxClient.new(user.dropbox_token)
            user.update_columns(dropbox_id: dc.account_info['uid'])
          rescue Exception => e
            puts "Error when tried to get id for user\##{user.id}: #{e.message}"
          end
        end
  end
end