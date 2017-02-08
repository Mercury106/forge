class Version < ActiveRecord::Base
  module Sockets
    extend ActiveSupport::Concern
    
    require "pusher"
    
    included do
      after_create :send_created
      after_save :send_push_for_percent_deployed
    end
      
    def send_created()
      # Pusher.url = "http://aad753d9df8692921f10:4c16fcffc492778ca200@api.pusherapp.com/apps/48120"
      if self.site
        self.site.pusher_channels.each do |channel|
          # Pusher[channel].trigger('version_created', VersionSerializer.new(self).as_json)
          Pusher[channel].trigger('site_update', SiteSerializer.new(self.site).as_json)
        end
      end
    end
    
    def send_push_for_percent_deployed()
      # Pusher.url = "http://aad753d9df8692921f10:4c16fcffc492778ca200@api.pusherapp.com/apps/48120"
      if self.site
        self.site.pusher_channels.each do |channel|
          
          pusher_hash = {}
          self.changed.each do |changed_column|
            next if changed_column == :updated_at
            pusher_hash[changed_column] = self[changed_column]
          end
          pusher_hash[:id] = self.id
          Pusher[channel].trigger 'version_update', VersionSerializer.new(self).as_json
        end
      end
    end  
    
  end
end