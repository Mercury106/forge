class NewsItemObserver < ActiveRecord::Observer

  observe Site, Version, User

  def after_create(object)
    item = NewsItem.new

    if object.is_a? Site
      item.site = object
      item.user = object.user
      item.action = "created"
    end

    if object.is_a? User
      item.site = nil
      item.user = object
      item.action = "signed up"
    end

    if object.is_a? Version
      item.site = object.site
      if object.site && object.site.user
        item.user = object.site.user
      end
      item.action = "uploaded version #{object.scoped_id} to"
    end

    item.save()
  end

end
