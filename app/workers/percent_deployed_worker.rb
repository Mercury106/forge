class PercentDeployedWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  
  def perform(version_id, percent)
    # I'm trying to decrease update calls, so I'll update only if 
    # percent % 2 != 0 or we have final call with 1001 percent
    Version.where('id = ? AND percent_deployed < ?', version_id, percent).update_all(
      percent_deployed: percent
    ) if percent.to_i == 1001 || percent.to_i % 2 > 0
    v = Version.find(version_id)
    v.site.pusher_channels.each do |channel|
      Pusher[channel].trigger 'version_update', VersionSerializer.new(v).as_json
    end
  end
end