#encoding: UTF-8

class User < ActiveRecord::Base
  module Oauth
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        after_save :update_site_tokens_if_deleting_oauth_tokens
      end
    end

    def update_site_tokens_if_deleting_oauth_tokens

      if self.github_token_changed?
        if !self.github_token 

          # They've unsynced their Github account
          sites.where("github_path is not null").each do |site|
            puts "Unsyncing #{site.url} from github"
            site.github_path = nil
            site.save
          end
        end
      end


      if self.dropbox_token_changed?
        if !self.dropbox_token

          # They've unsynced their Dropbox account
          self.sites.where("dropbox_path is not null").each do |site|
            puts "Unsyncing #{site.url} from dropbox"
            site.dropbox_path = nil
            site.save
          end
        end
      end
    end
  end
end