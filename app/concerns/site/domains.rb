# This module handles which users are allowed to create sites on which domains.

class Site < ActiveRecord::Base
  module Domains
    extend ActiveSupport::Concern
    
    included do
      validate :user_owns_root_domain, :on => :create
      validates_presence_of :url
      validates_presence_of :user_id
      before_save :downcase_url
    end

    def downcase_url
      self.url = self.url.downcase
    end
    
    def user_owns_root_domain
      return unless self.url
      return if self.url.ends_with? ".getforge.io"
      
      domain = PublicSuffix.parse(self.url)
      hostname = domain.domain
      d = Domain.where(:url => hostname).first
      if !d
        Domain.create(:url => hostname, :user => self.user)
      else
        if d.user_id != self.user_id
          errors.add(:base, "#{hostname} is already in use by another user!")
        end
      end
    rescue PublicSuffix::DomainInvalid => e
      # Why's this a comment?
      # I guess we will never know
      # TODO: test this bit.
      
      # #haikumments
      
      # errors.add(:url, "is not a valid URL.")
    end
    
  end
end