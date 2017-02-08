class WebhookTriggerWorker
  include Sidekiq::Worker

  def perform(event_name, site_id, repeat = 0, args = {})
    @webhooks = YAML.load_file('config/webhooks.yml')
    if @webhooks['events'].keys.include? event_name
      trigger(event_name, site_id, repeat, args)
    end
  end

  def trigger(event_name, site_id, repeat, args)
    # use 'map' instead of 'each' for testing purposes (return values)
    hooks = WebhookTrigger.where(event: event_name, site_id: site_id).map do |trigger|
      trigger.send_hook(repeat, args)
    end
    # send request to nodejs app, force cache cleaning
    if event_name == 'deploy_success'
      site = Site.find(site_id)
      Net::HTTP.get(URI.parse("http://#{site.url}/_asgard_cache_buster"))
    end
    hooks
  end
end

