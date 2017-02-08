require 'dropbox_sdk'
class DropboxHookWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_dropbox_id)
    @user = User.find_by(dropbox_id: user_dropbox_id)
    return if @user.blank?
    @user.sites.each do |s|
      return if s.dropbox_path.blank? || !s.dropbox_autodeploy
      delta = dropbox_client.delta(s.dropbox_cursor, s.dropbox_path)
      s.update_column('dropbox_cursor', delta['cursor'])
      delta['entries'].reject!{ |entry| entry[1] == nil } # do not deploy if files were deleted
      if delta['entries'].any?
        s.redeploy!
      end
    end
  end

  def dropbox_client
    @dropbox_client ||= DropboxClient.new(@user.dropbox_token)
  end
end
