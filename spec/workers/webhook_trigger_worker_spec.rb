require 'rails_helper'

describe WebhookTriggerWorker, type: :worker do
    before do
      @site = create(:site)
      YAML.load_file('config/webhooks.yml')['events'].keys.each do |event_name|
        create(:webhook_trigger,
               url: "examplehook.com/#{event_name}",
               event: event_name,
               http_method: 'GET',
               site: @site)
      end
    end
    YAML.load_file('config/webhooks.yml')['events'].keys.each do |event_name|
      it "should send '#{event_name.humanize}' webhook" do
        stub_request(:get, "http://examplehook.com/#{event_name}?text=foo")
         .with(headers: {'Accept'=>'*/*'})
         .to_return(status: 200, body: event_name, headers: {})

        @worker = WebhookTriggerWorker.new
        stub_request(:get, "http://#{@site.url}/_asgard_cache_buster") if event_name == 'deploy_success'
        result = @worker.perform(event_name, @site.id, 0)
        expect(result).to eq([event_name])
      end
    end
end


