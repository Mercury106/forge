module Version::ScopedId
  
  extend ActiveSupport::Concern
  
  included do
    before_create :populate_scoped_id
  end

  def populate_scoped_id
    if site
      self[:scoped_id] = site.latest_scoped_version_id.to_i
      site.increment!(:latest_scoped_version_id)
    end
  end
end