class ApplicationController < ActionController::Base
  
  protect_from_forgery

  before_filter :sleep_in_development_mode, except: :public, :if => lambda {|c| Rails.env.development? }

  before_filter :clear_background_queue_in_development, :if => lambda {|c| Rails.env.development? }
  def clear_background_queue_in_development
    # Version.includes(:site).where("percent_deployed < 100").each do |version|
    #   version.percent_deployed = 100
    #   version.save()
    # end
    # QC.default_queue.delete_all
  end
  
  def public
    if current_user
      render 'ui/index', :layout => "application"
    else
      render 'public/index', :layout => 'teaser'
    end
  end
  
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    if !current_user
      redirect_to new_user_session_path
    else
      redirect_to sites_path, :message => "You're not allowed to do that!"
    end
  end

  private
  
  def sleep_in_development_mode
    sleep 0.5
  end
  
  # For this example, we are simply using token authentication
  # via parameters. However, anyone could use Rails's token
  # authentication features to get the token from a header.
  def authenticate_user_from_token!
    user_token = params[:user_token].presence
    user       = user_token && User.find_by_authentication_token(user_token.to_s)
  
    if user
      # Notice we are passing store false, so the user is not
      # actually stored in the session and a token is needed
      # for every request. If you want the token to work as a
      # sign in token, you can simply remove store: false.
      sign_in user, store: false
    end
  end
end