class ApiController < ApplicationController

  # Remove it in next versions!
  def deployed
    # ip = request.remote_ip
    # key = "last_deployment_request:#{ip}"
    # last_request = Rails.cache.read(key) || 1.minute.ago
    # Rails.cache.write(key, Time.now)
    # render :json => Deployment.where("updated_at > ?", 1.minute.ago).collect(&:url).to_json
    render :json => Site.select(:url).where("deployed_at > ?", 1.minute.ago).collect(&:url).to_json
  end

  # An updated version of deployed method with support
  # of site configs and arbitrary check period
  def deployed_sites
    deployed_since = if params[:deployed_since]
      Time.at( params[:deployed_since].to_i )
    else
      1.minute.ago
    end

    # Assume that max downtime of deleter is 2 days
    # After that we have to redeploy manually
    deployed_since = [ deployed_since, 2.days.ago ].max

    payload = Site.order(deployed_at: :asc)
      .where('deployed_at > (?)', deployed_since)
      .includes(:current_version)
      .map do |site|
        {
          url: site.url,
          deployed_at: site.deployed_at,
          has_config:  site.current_version.siterc.present?
        }
      end

    render json: { sites: payload }
  end

  def site_meta
    url = params.fetch(:url, '')
    @site = Site.fetch_by_url(url)

    if @site.nil?
      render json: { error: :site_not_found }, status: :not_found and return
    end

    @version = @site.current_version
    render json: {
      siterc: @version.siterc,
      token:  @version.deploy_slug
    }
  end

  def authenticate
    render :json => User.first.to_json(:only => [:email, :authentication_token])
  end

  def sites
    render :json => current_user.sites.to_json(:methods => [:bandwidth_this_month], :include => {:versions => {:methods => :diff}})
  end

  def create
    s = current_user.sites.new(:url => params[:url])
    if s.save
      render :json => {:success => true}
    else
      render :json => {:success => false}, :status => 500
    end
  end

  before_filter :find_user
  def find_user
    if params[:email]
      user = User.find_for_database_authentication(:email => params[:email])

      if user.valid_password?(params[:password])
        sign_in user
        @user = user
      else
        render :json => {:success => false, :message => "Invalid login"}
        return
      end
    end
  end

  def upload
    @site = current_user.sites.find_by_url(params[:url])
    version = @site.versions.new()
    version.upload = params[:data]
    version.description = "Uploaded via API"
    if version.save
      @site.current_version = version
      @site.save()
      render :head => :ok, :text => ""
    else
      render :head => :error
    end

  end

end
