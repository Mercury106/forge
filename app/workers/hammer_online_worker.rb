class HammerOnlineWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(site_id)
    ActiveRecord::Base.connection_pool.with_connection do
      site = Site.find(site_id)
      version = site.current_version
      user = site.user
      user.generate_guid! if user.guid.blank?
      uri = URI.parse(ENV['HAMMER_COMPILER_URL'])
      ConsoleLogger.version_id = version.id
      begin
        response = Net::HTTP.post_form(uri,
          guid: user.guid,
          archive_url: version.upload.url,
          user_token: user.authentication_token,
          site_url: site.url,
          access_token: Digest::SHA1.hexdigest(Date.today.to_s)
        )
        if response.code.to_i != 200
          ConsoleLogger.fail('[hammer online] compilation failed, compilation service is down')
        else
          ConsoleLogger.ok('[hammer online] webhook was sent, awaiting response')
        end
      rescue
        ConsoleLogger.fail('[hammer online] compilation failed, compilation service is not accessible')
      end
    end
  end
end