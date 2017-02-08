class SiteUsageSerializer < ActiveModel::Serializer
  
  # cached
  
  attributes :bytes, :date
  
  def datetime
    object.date.to_time + hour.hours
  end
  
end