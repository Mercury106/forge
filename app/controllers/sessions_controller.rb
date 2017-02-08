class SessionsController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:create]
  
  respond_to :json
  
  def show
    render json: session_json(current_user)
  end
  
  def new
    redirect_to "/"
  end
  
  def create
    user = User.find_for_database_authentication(email: params[:session][:email])
    
    if user && user.valid_password?(params[:session][:password])
      
      sign_in user
      current_user.remember_me!

      if params[:session][:remember_me]
        cookies.signed["remember_user_token"] = {
          :value => user.class.serialize_into_cookie(user.reload),
          :expires => 3.months.from_now
        }
      end
      
      respond_to do |format|
        format.html { redirect_to root_url }
        format.json do
          render json: session_json(user), status: :created
        end
      end
    else
      respond_to do |format|
        format.json {
          render json: {
            errors: {
              email: "invalid email or password"
            }
          }, status: :unprocessable_entity
        }
        format.html {redirect_to root_url}
      end
    end
  end

  def destroy
    sign_out :user
    respond_to do |format|
      format.json {
        render json: {}, status: :accepted
      }
      format.html {
        redirect_to root_url
      }
    end
  end
  
  def update
    if user_params
      
      if user_params[:password].blank?
        user_params.delete :password
      end

      if user_params[:dropbox_token].present?
        DropboxGetUserIdWorker.perform_async(current_user.id, params[:session][:dropbox_token])
      end
      # do not allow to update plan_id directly
      plan_id = user_params.delete(:plan_id)
      if current_user.update_attributes(user_params)
        # billing update / create
        if user_params[:stripe_card_token]
          current_user.process_billing(plan_id)
          current_user.save
        elsif plan_id && current_user.plan_id != plan_id
          current_user.change_plan!(plan_id)
        end

        sign_in current_user, :bypass => true
        render json: session_json(current_user)
      else
        render json: {errors: current_user.errors}, status: :unprocessable_entity
      end
    else
      render json: {}
    end
  end
  
  private

  def user_params
    params[:session]
  end
  
  def session_json(user=false)
    if user
      # {session: {id: 1, email: current_user.email, name: current_user.name, user: {email: current_user.email}}}
      {session: UserSerializer.new(current_user).as_json(:root => false)}
    else
      {errors: [{email: "invalid email or password"}]}
    end
  end
end