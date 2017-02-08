class VersionsController < ApplicationController
  
  respond_to :json
  # before_filter :authenticate_user!
  load_and_authorize_resource

  skip_before_filter :verify_authenticity_token

  def publish
    # version change
    @site.previous_version = @site.current_version
    @site.current_version = @version
    @site.save()
    # @version.site.update_attribute :current_version_id, @version.id
    respond_with @version
  end

  # GET /versions
  # GET /versions.json
  def index
    if params[:site_id]
      @site = current_user.sites.find params[:site_id]
      respond_with @site.versions
    else
      respond_with @versions
    end
  end

  # GET /versions/1
  # GET /versions/1.json
  def show
    respond_with @version
  end

  # POST /versions
  # POST /versions.json
  def create

    if params[:site_id]
      @version.site = current_user.sites.find(params[:site_id])
      @site = @version.site
    end
    
    if @version.save
      # version change
      @version.site.previous_version = @version.site.current_version
      @version.site.current_version = @version
      @version.site.save
      @version.site.deploy_from_right_source
    end

    respond_with @version
  end

  # PUT /versions/1
  # PUT /versions/1.json
  def update
    @version.update_attributes(params[:version])
    respond_with @version
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @version.destroy
    respond_with @version
  end
  
  def download
    path = @version.upload.url
    headers["Location"] = path
    redirect_to(path)         
  end
end
