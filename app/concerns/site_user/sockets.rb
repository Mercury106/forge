class SiteUser < ActiveRecord::Base
  module Sockets
    extend ActiveSupport::Concern
    
    included do
      after_save :send_push
      after_destroy :send_delete_push
    end
    
    def pusher_channels
      if self.site
        self.site.pusher_channels
      else
        []
      end
    end
    
    def send_push
      
      # TODO: Check whether we need to reload the site first to get the pusher_channels
      self.site.reload()
      
      pusher_channels.each do |channel|
        Pusher[channel].trigger('site_update', SiteSerializer.new(self.site).as_json)
      end
    end
    
    def send_delete_push
      pusher_channels.each do |channel|
        Pusher[channel].trigger('site_users:delete', {site: {id: site_id}})
      end
    end
  end 
end