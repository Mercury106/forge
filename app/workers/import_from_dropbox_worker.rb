class ImportFromDropboxWorker
  include Sidekiq::Worker

  def perform(version_id)
    version = Version.find(version_id)
    ConsoleLogger.status(
      "Deploying #{version.site.url} [version ##{version.scoped_id}]",
      version_id
    )
    ConsoleLogger.ok('Downloading files from Dropbox')

    Version.import_from_dropbox_without_delay(version_id)
    version.site.deploy
  end
end