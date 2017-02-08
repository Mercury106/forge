class UserSerializer < ActiveModel::Serializer
  
  attributes :id, :email, :name, :billing_complete, :subscription_active, :country, :plan_id, :maximum_number_of_sites, :created_at, :dropbox_token, :github_token

  def billing_complete
    !object.stripe_customer_token.nil?
  end

end