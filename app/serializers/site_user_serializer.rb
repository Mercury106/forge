class SiteUserSerializer < ActiveModel::Serializer
  
 # cached
  
  attributes :id, :user_id, :site_id, :email

  def email
    object.user.email
  end
  
end
