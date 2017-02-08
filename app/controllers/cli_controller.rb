class CliController < ApplicationController
  include ActionView::Helpers::TextHelper

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user, except: :login

  def login
    user = User.find_by(email: params[:email])
    if user && user.valid_password?(params[:password])
      render json: { name: user.name, token: user.authentication_token }
    else
      render json: { error: 'Incorrect email or password.' }, status: 401
    end
  end

  def create
    if Site.where(url: "#{params[:name]}.getforge.io").count > 0
      render json: { error: "Name '#{params[:name]}' was taken already." },
             status: 422
      return
    end
    if @user.plan_id.blank? && @user.sites.count == 0 ||
       @user.plan_id == 'free' && @user.sites.count == 0 ||
       @user.plan_id == 'basic' && @user.sites.count < 10 ||
       @user.plan_id == 'pro'
      site = Site.new(user_id: @user.id, url: params[:name])
      if site.save
        head :ok
      else
        render json: { error: site.errors.full_messages.first }, status: 422
      end
    else
      render json: { error: [ 
          "You already have #{pluralize(@user.sites.count, 'site')}. ",
          'Please, upgrade your subscription in order to get more sites.'
        ].join
      }, status: 422
    end
  end

  def sites
    render json: @user.sites.map(&:url), root: false
  end

  def deploy
    site = @user.sites.find_by(url: params[:domain])
    if site.nil?
      render json: { error: "No such site '#{params[:domain]}'."}, status: 422
      return
    end
    version = Version.new(site_id: site.id)
    old_version = site.current_version
    version.upload = params[:archive]
    version.save
    site.update_columns(current_version_id: version.id,
                        previous_version_id: old_version.try(:id))
    SiteDeployWorker.perform_async(site.id)
    head :ok
  end

  private

  def authenticate_user
    if params[:token].blank?
      render json: { error: 'You are not authenticated' }, status: 401
      return
    end
    @user = User.find_by(authentication_token: params[:token])
    return true if @user.present?
    render json: { error: 'Your token is expired.' }, status: 401
    return
  end
end
