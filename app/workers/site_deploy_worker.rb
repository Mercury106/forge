class SiteDeployWorker
  include Sidekiq::Worker

  def perform(site_id, redeploy = false)
    site = Site.find(site_id)
    if redeploy
      site.current_version.update_column(:created_at, Time.zone.now)
      ConsoleLogger.version_id = site.current_version_id
      ConsoleLogger.redeploy
    end
    ConsoleLogger.status(
      "Deploying #{site.url} [version ##{site.current_version.scoped_id}]",
      site.current_version_id
    )
    Site.deploy_by_id(site_id)
  end
end