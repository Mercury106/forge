class SiteLogWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(site_id, message)
    Site::Sockets.send_log_by_id(site_id, message)
  end
end