class Users::InvitationsController < Devise::InvitationsController

  layout 'teaser'
  
  before_filter :hide_buttons
  def hide_buttons
    @hide_login = true
  end
  
  before_filter :authenticate_user!, :only => [:create]
  
  def create
    self.resource = resource_class.invite!(resource_params, current_inviter)

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      redirect_to sites_url
    else
      respond_with_navigational(resource) { render :new }
    end

  end
  
  def has_invitations_left?
    unless current_inviter.nil? || current_inviter.has_invitations_left?
      build_resource
      set_flash_message :alert, :no_invitations_remaining
      respond_with_navigational(resource) { render :new }
    end
  end

end