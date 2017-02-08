# class AccountsController < ApplicationController

#   before_filter :authenticate_user!
  
#   # load_and_authorize_resource :user
  
#   def show
#     @user = current_user
#     @sites = current_user.sites.includes(:site_usages)
#   end
  
#   def update
    
#     return render :text => "Uh-oh" unless params[:user]
    
#     @user = current_user
#     @user.attributes = params[:user]
    
#     # if params[:user][:stripe_card_token] != ""
#       # success = @user.save_with_stripe_card_token_and_create_stripe_customer()
#     # else
#       success = @user.save
#     # end
    
#     respond_to do |format|
#       if success
#         sign_in @user
#         format.html { redirect_to account_path, notice: 'Account was successfully updated.' }
#         format.json { head :no_content }
#       else
#         format.html { render action: "show" }
#         format.json { render json: @user.errors, status: :unprocessable_entity }
#       end
#     end
#   end
  
#   def change_card
#     @user = current_user
#   end
  
#   def invoices
#     @invoices = []
#     if current_user.stripe_customer_token
#       @invoices = current_user.invoices
#     end
#   end
  
# end
