module Forge
  class Env
    def self.load
      return unless local_env?
      require 'dotenv'
      Dotenv.load '.env.local', '.env'

      # Pusher pulls the URL from the ENV when required. Manually set it.
      Pusher.url = ENV['PUSHER_URL'] if defined?(Pusher)
    end

    def self.local_env?
      ENV['RACK_ENV'].nil? ||
        ENV['RACK_ENV'] == 'development' or
        ENV['RACK_ENV'] == 'test'
    end
  end
end

Forge::Env.load
