class Site < ActiveRecord::Base
  module Favicon

    extend ActiveSupport::Concern

    def favicon_url
      Rails.cache.fetch([self, :favicon, :url]) do
        require "open-uri"
        favicon_redirect_url = "http://#{self.url}/favicon.ico"
        begin
          open(favicon_redirect_url)
        rescue
          favicon_redirect_url = "/assets/favicon.ico"
        end

        favicon_redirect_url
      end
    end

    # included do
    #   has_attached_file :favicon, :default_url => "/assets/favicon.ico"
    # end

    # def fetch_favicon!
    #   require "open-uri"
    #   image_url = "http://#{url}/favicon.ico"

    #   begin
    #     result = open(image_url)
    #   rescue 
    #     image_url = "https://getforge.com/assets/favicon.ico"
    #     result = open(image_url)
    #   end

    #   self.favicon = result
    #   save()
    # end
    
  end
end
