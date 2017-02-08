ActiveAdmin.register User do

  filter :email
  filter :name
  filter :number_of_free_gigabytes
  filter :created_at
  
  action_item('Invite') do
    link_to 'Invite New User', new_invitation_admin_users_path
  end

  action_item('Sing In', only: :show) do
    link_to 'Sign in as this user', sign_in_as_admin_user_path, :target => "_blank"
  end
  
  collection_action :new_invitation do
    @user = User.new
  end

  member_action :sign_in_as do
    user = User.find(params[:id])
    sign_in user
    redirect_to root_url
  end

  collection_action :send_invitation, :method => :post do
    @user = User.invite!(params[:user], current_user)
    if @user.errors.empty?
      flash[:success] = "User has been successfully invited." 
      redirect_to admin_users_path
    else
      messages = @user.errors.full_messages.map { |msg| msg }.join
      flash[:error] = "Error: " + messages
      redirect_to new_invitation_admin_users_path
    end
  end
  
  form do |f|
    f.inputs "Details" do
      f.input :name, :input_html => {:autocomplete => :off}
      f.input :email, :input_html => {:autocomplete => :off}
      f.input :password, :input_html => {:autocomplete => :off}

      f.input :github_token, :input_html => {:autocomplete => :off}
      f.input :dropbox_token, :input_html => {:autocomplete => :off}
      f.input :dropbox_id
    end
    f.actions
  end

  collection_action :all, :method => :get do
    json = Rails.cache.fetch("users:all:json", :expires_in => 2.hours) do
      User.order("created_at asc").all.to_json
    end
    render :json => json
  end

  collection_action :paid, :method => :get do
    json = Rails.cache.fetch("users:paid:json", :expires_in => 2.hours) do
      User.where("stripe_customer_token is not null").order("created_at asc").all.to_json
    end
    render :json => json
  end
  
  index do
    selectable_column
    column :email
    column :sites do |user|
      user.sites.count
    end
    column :sign_in_count
    column :created_at
    column :number_of_free_gigabytes
    actions
  end

  show do
    attributes_table do
      row :email
      row :number_of_free_gigabytes
      row :coupon
      row :authentication_token
      row "Sites" do
        render 'sites'
      end
    end
  end

  controller do
    def update
      @user = User.find(params[:id])
      if params[:user][:password].blank?
        @user.update_without_password(params[:user])
      else
        @user.update_attributes(params[:user])
      end

      if @user.errors.blank?
        redirect_to admin_users_path, :notice => "Updated successfully."
      else
        render :edit
      end
    end
  end
end
