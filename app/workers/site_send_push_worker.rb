class SiteSendPushWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(site_id)
    Site::Sockets.send_push_by_id(site_id)
  end
end