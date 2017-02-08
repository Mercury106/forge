FactoryGirl.define do
  factory :webhook_trigger do
    user
    site
    sequence(:http_method) { ['GET', 'POST'].sample }
    sequence(:event) { YAML.load_file('config/webhooks.yml')['events'].map { |e, v| e }.sample }
    url 'example.com'
    parameters 'text=foo'
  end
end