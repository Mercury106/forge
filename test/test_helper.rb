require "test/unit"
require 'rails'
require 'net-http-spy'

ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/setup'
require 'vcr'
require 'fakeweb'

class ActionController::TestCase
  include Devise::TestHelpers
end

VCR.configure do |c|
  c.hook_into :fakeweb
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.default_cassette_options = { :record => :new_episodes }
  c.allow_http_connections_when_no_cassette = true

  # c.around_http_request do |request|
  #   VCR.use_cassette('global', :record => :new_episodes, &request)
  # end
end

class ActiveSupport::TestCase
  setup do
    VersionDeployer.any_instance.stubs(:deploy_slug).returns("deploy-slug")
    Site.any_instance.stubs(:generate_first_version).returns(true)
  end
end

module FakeWeb
  class StubSocket
    def read_timeout=(ignored)
    end
    def continue_timeout=(ignored)
    end
  end
end

StripeDummyConstants = {
  'invoice_id' => 'invoice id',
  'period_start' => 1380033727,
  'period_end' => 1382625727,
  'customer_token' => 'customer_token'
}

StripeDummyData = {
  'invoice.created' => {
    "type" => "invoice.created",
    "data" => {
      "object" => {
        "id" => StripeDummyConstants['invoice_id'],
        "customer" => StripeDummyConstants['customer_token'],
        "period_start" => StripeDummyConstants['period_start'],
        "period_end" => StripeDummyConstants['period_end']
      }
    }
  },

  'invoice.payment_succeeded' => {
    'type' => 'invoice.payment_succeeded',
    'data' => {
      'object' => {
        'customer' => StripeDummyConstants['customer_token']
      }
    }
  },

  'invoice.payment_failed' => {
    'type' => 'invoice.payment_failed',
    'data' => {
      'object' => {
        'customer' => StripeDummyConstants['customer_token']
      }
    }
  },

  'customer.subscription_created' => {
    "type" => "customer.subscription_created",
    "data" => {
      "object" => {
        "customer" => StripeDummyConstants['customer_token']
      }
    }
  },

  'customer.deleted' => {
    "type" => "customer.subscription_deleted",
    "data" => {
      "object" => {
        "customer" => StripeDummyConstants['customer_token']
      }
    }
  }
}