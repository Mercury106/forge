class UsersController < ApplicationController
  
  respond_to :json
  def show
    respond_with current_user
  end

  def check_user
    user = User.find_by(email: params[:email])
    if user.present?
      render json: { exist: true, plan: user_plan_number(user) }
    else
      render json: { exist: false }
    end
  end

  private

  def user_plan_number(user)
    case user.plan_id
    when 'basic' then 1
    when 'pro' then 2
    else 0
    end
  end
end