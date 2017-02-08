module Bandwidth
  
  extend ActiveSupport::Concern
  
  def bandwidth_in_month(date)
    usages = site_usages.in_month_of(date)
    usages.inject(0) { |sum, site_usage| sum + site_usage.bytes }
  end

  def bandwidth_range(range)
    site_usages.where('date > ? AND date < ?', range.begin, range.end).sum("bytes")
  end

  def bandwidth_on_day(date, hour=nil)
    conditions = {date: date}
    conditions[:hour] = hour if hour
    site_usages.where(conditions).where(:site_id => self.id)..where("bytes is not null").sum(&:bytes)
  end
  
  def bandwidth_since(date)
    site_usages.unscoped.since(date).where(:site_id => self.id).select("sum(bytes) as bytes").load.first.bytes.to_i
  end
  
  def bandwidth_this_month
    bandwidth_since Date.today.beginning_of_month
  end
  
end
