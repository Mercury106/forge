class SiteUsage < ActiveRecord::Base
  
  belongs_to :site, touch: true

  attr_accessible :bytes, :cdn_bytes, :date, :hour
  
  scope :in_month_of, lambda { |date|
    where("site_usages.created_at > ? and site_usages.created_at < ?", date.beginning_of_month, date.end_of_month)
  }
  
  scope :between, lambda {|a, b|
    where("site_usages.created_at > ? and site_usages.created_at < ?", a, b)
  }
  
  scope :since, lambda {|date|
    where("site_usages.created_at > ?", date)
  }
  
  def cache_key
    id
  end
  
end
