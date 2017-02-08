require 'dropbox_sdk'
class DropboxGetUserIdWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, dropbox_token)
    dc = DropboxClient.new(dropbox_token)
    User.where(id: user_id).update_all(dropbox_id: dc.account_info['uid'])
  end
end