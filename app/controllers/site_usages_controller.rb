class SiteUsagesController < ApplicationController
  
  respond_to :json
  
  load_and_authorize_resource :site
  
  def index
    site_usages = @site.site_usages
    
    if params[:start_date] && params[:end_date]
      site_usages = site_usages.where("date > ? and date > ?", Date.parse(params[:start_date]), Date.parse(params[:end_date]))
    else
      site_usages = site_usages.where("date > ?", 1.month.ago)
    end
    
    group_column = "date_trunc('day', date)"
    
    site_usages = site_usages
      .select("sum(bytes) as bytes, #{group_column} as date").group(group_column)
      .order("date asc")
    respond_with site_usages
  end
  
end