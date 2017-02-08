class SiteUser < ActiveRecord::Base
  
  include SiteUser::Sockets if Rails.env.production?
  
  attr_accessor :email
  attr_accessible :site_id, 
                  :user_id, 
                  :email, 
                  :user, 
                  :user_attributes

  # If you set the email property, we have to ensure that this email matches an existing user.
  before_validation :set_user_from_email
  
  belongs_to :user
  validates_presence_of :user
  accepts_nested_attributes_for :user
  validates_uniqueness_of :user_id, :scope => :site_id
  
  belongs_to :site, :touch => true
  validates_uniqueness_of :site_id, :scope => :user_id

  after_save :touch_site
  after_destroy :touch_site
  def touch_site
    self.site.touch()
    self.site.save()
  end
  
private

  def set_user_from_email
    if self.email
      
      # First, make sure that the email doesn't have spaces
      self.email = self.email.to_s.strip.downcase
      
      user = User.find_by_email(email)
      
      if !user
        self.user = User.invite!(:email => email)
      else
        self.user = user
      end
      
    end
  end
  
end