class SitesController < ApplicationController
  
  before_filter :authenticate_user!

  load_resource :only => :favicon
  load_and_authorize_resource :except => :favicon

  skip_before_filter :sleep_in_development_mode, :only => [:favicon, :public]
  
  respond_to :json, :js

  def bootstrap
    # @sites = Site.accessible_by(Ability.new(current_user))
    # @sites = @sites.includes(:versions)
    # respond_with @sites
    render :text => ""
  end

  # GET /sites
  # GET /sites.json
  def index
    respond_with @sites
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    render :json => {site: []}
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    respond_with @site
  end

  # POST /sites
  # POST /sites.json
  def create
    @site.user = current_user
    if @site.save
      respond_with @site
    else
      render template: "public#index"
    end
  end

  # TODO: Find a better way to ensure these are the right attributes.
  # Allowable Object attributes need checking.

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    params[:site][:site_users_attributes] = params[:site].delete(:site_users)
    
    params[:site].delete(:user)
    params[:site].delete(:users)
    params[:site].delete(:created_at)
    params[:site].delete(:updated_at)
    
    if params[:site][:site_users_attributes]
      params[:site][:site_users_attributes].each do |site_user|
        site_user[:user_attributes] = site_user.delete(:user)
        site_user.delete(:user_attributes) if site_user[:user_attributes].blank?
      end
    else
      params[:site].delete(:site_users_attributes)
    end
    
    @site.assign_attributes(params[:site])
    create_or_destroy_github_hook(@site)
    # version change
    @site.previous_version_id =  @site.current_version_id_was if @site.current_version_id_changed?
    @site.dropbox_autodeploy = false if @site.dropbox_path_changed?
    @site.github_autodeploy = false if @site.github_path_changed?

    needs_deploy = @site.current_version_id_changed? || @site.url_changed?
    if @site.save
      @site.deploy if needs_deploy
      render json: @site
    else
      respond_with @site
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site.destroy
    respond_with @site
  end
  
  # The CDN replacement part of the thing, for the iFrame. 
  # Only in development mode.
  def public
    filename = "#{params[:filename]}.#{params[:format]}"
    filename = "index.html" if filename == "."
    format = params[:format] || "html"

    @site ||= Site.find_by_url(request.host)
    @site ||= Site.find(request.subdomain.to_i)
    
    version = @site.current_version
    root_file = version.file_hash.keys.find do |file|
      file =~ /^index.html?/
    end
    root_file ||= 'index.html'

    public_file_url = "https://#{ENV['AWS_BUCKET']}.s3.amazonaws.com/#{@site.url}/#{@site.current_deploy_slug}/#{filename}"
    root = "https://#{ENV['AWS_BUCKET']}.s3.amazonaws.com/#{@site.url}/#{root_file}"

    if format == "html"
      require "open-uri"
      if Rails.env.development?
        text = open(root).read
      else
        text = Rails.cache.fetch [@site.id, version.id, @site.updated_at, version.updated_at, version.deployed_at] do
          text = open(root).read.gsub("http://#{ENV['CDN_HOST']}",
                                      "https://#{ENV['AWS_BUCKET']}.s3.amazonaws.com")
        end
      end
      return render :text => text, :layout => false
    else
      redirect_to public_file_url
    end
    return
  rescue
    render 'cdn_error', :layout => false
  end
  
  def favicon
    expires_in 1.day, :public => true
    redirect_to @site.favicon_url
  end

  private

  def create_or_destroy_github_hook(site)
    return unless site.github_autodeploy_changed?
    if site.github_autodeploy
      GithubHookWorker.create_hook(site.id)
    else
      GithubHookWorker.destroy_hook(site.id)
    end
  end
end
