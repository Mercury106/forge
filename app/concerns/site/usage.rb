# This Usage module is just for
# - Adding usage (bandwidth) to a site
# - Checking usage since the last time a user was billed.
# Maybe this should be called 'billing' rather than 'usage'.
# Either way it depends on the Bandwidth module to know how much unbilled usage we have.

class Site < ActiveRecord::Base
  module Usage
    
    extend ActiveSupport::Concern
    
    included do
      has_many :site_usages, :dependent => :delete_all    
    end
    
    def unbilled_usage
      bandwidth_since self.last_invoiced_at || 10.years.ago
    end
    
    def add_usage(bytes, date=Time.now)
      # Site usage is rounded by day so we don't end up with tons of usage.
      site_usages.find_or_create_by(date: date.beginning_of_day).increment! :bytes, bytes.to_i
    end
    
    def mark_as_billed!
      self.update_attribute :last_invoiced_at, Time.now()
      # TODO: Delete or consolidate old site_usages.
    end
    
  end
end