module ApplicationHelper

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def round_for_currency(number)
    "%0.2f" % number
  end

  def price_this_month
    if @price_this_month
      "%.2f" % (@price_this_month.to_f / 100)
    end
  end
end
