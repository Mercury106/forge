class Site < ActiveRecord::Base
  module Sockets

    extend ActiveSupport::Concern

    included do
      after_save :send_push unless Rails.env.test?
    end

    def pusher_channels
      users.collect(&:pusher_channel)
    end

    def send_push
      SiteSendPushWorker.perform_async(self.id)
    end

    def self.log_by_id(id, message)
      SiteLogWorker.perform_async(id, message)
    end

    def self.send_log_by_id(id, message)
      site = Site.find(id)
      # site.reload() # TODO remove this line if everything is ok
      site.pusher_channels.each do |channel|
        Pusher[channel].trigger('log', message)
      end
    end

    def self.send_push_by_id(id)
      site = Site.find(id)
      site.reload()
      site.pusher_channels.each do |channel|
        Pusher[channel].trigger('site_update', SiteSerializer.new(site).as_json)
      end
    end
  end
end