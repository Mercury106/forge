class SiteUsersController < ApplicationController
  
  respond_to :json
  
  load_and_authorize_resource 
  # load_and_authorize_resource :through => :site
  
  # before_filter :load_site
  # def load_site
  #   @site = current_user.sites.find(params[[:site_id])
  # end
  
  def index
    # if params[:site_id]
      # @site = Site.find(params[:site_id])
      # respond_with @site.site_users
    # else
    if params[:ids]
      respond_with @site_users.where(:id => params[:ids])
    else
      respond_with @site_users.where(:site_id => params[:site_id])
    end
    # end
  end
  
  def create
    site_params = params[:site_user].delete(:site)
    
    @site = Site.find(params[:site_user][:site_id])
    
    @site_user = SiteUser.new(params[:site_user])
    @site_user.save()

    @site.reload()
    
    respond_with @site_user
    # site_users = @site.site_users
    # respond_with site_users
  end
  
  def destroy
    @site_user = SiteUser.find(params[:id])
    @site_user.destroy()
    # @site.site_users.find_by_user_id(params[:id]).destroy()
    # redirect_to @site
    respond_with @site_user
  end
  
end
