require 'resolv'

class Site < ActiveRecord::Base
  module Dns
    extend ActiveSupport::Concern
    
    included do
      if !Rails.env.test?
        validate :url_dns_points_to_forge, :unless => :skip_url_dns_validation?
      end
    end
    
    def skip_url_dns_validation?

      return true unless url

      return true if errors.any?

      return true unless url_changed?

      return true if url.ends_with? '.getforge.io'
    end
    
    def url_dns_points_to_forge
      self.errors.add(:url, "does not point to #{ENV['EXTERNAL_IP']}") unless has_matching_record?
    rescue => e
      self.errors.add(:url, "could not be validated due to a system error: #{e}")
    end
    
  private

    def has_matching_record?
      has_cname || has_aliases || has_nameservers || has_a_records
    end
    
    def has_cname
      resources = Resolv::DNS.new.getresources(self.url, Resolv::DNS::Resource::IN::CNAME)
      records = resources.collect{|resource| resource.name.to_s rescue nil}.compact
      return records == [ENV['EXTERNAL_CNAME']]
    end
    
    def has_aliases
      aliases = Resolv::DNS.new.getresources(self.url, Resolv::DNS::Resource::IN::TXT).collect(&:strings).flatten rescue []
      if aliases.length > 0
        if aliases.include?("ALIAS for proxy.asgard.io") or aliases.include?("ALIAS for getforge.io")
          return true
        end
      end
    end
    
    # This one will be used for DNS management later on down the line.
    def has_nameservers
      our_nameservers = ENV['EXTERNAL_DNS'].to_s.split(",")
      their_nameservers = Resolv::DNS.new.getresources(self.url, Resolv::DNS::Resource::IN::NS).collect{|name| name.name.to_s}
      (our_nameservers & their_nameservers).length > 0
    end
    
    def has_a_records
      ips = Resolv::DNS.new.getresources(self.url, Resolv::DNS::Resource::IN::A).collect{|result| result.address.to_s}
      if ips.include? ENV['EXTERNAL_IP']
        return true
      end
    end
    
  end
end
