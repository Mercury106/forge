require "uri"
require "resolv"

class User < ActiveRecord::Base

  include Billing
  include Bandwidth
  include Oauth

  has_many :owned_sites, :dependent => :destroy, :class_name => "Site"
  has_many :site_users
  has_many :sites, :through => :site_users
  has_many :site_usages, :through => :sites
  has_many :forms, dependent: :destroy
  has_many :form_data, dependent: :destroy
  has_many :webhook_triggers, dependent: :destroy
  
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :invitable, :trackable, :registerable # , :confirmable

  before_save :ensure_authentication_token

  attr_accessible :email, :password, :password_confirmation, :remember_me,
                  :dropbox_id, :name, :country, :dropbox_token, :github_token

  validates_presence_of :email #, :name

  def validate_host(host)
    host = URI.parse("http://#{host}").host
    records = Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::CNAME)
    records.first.name.to_s == self.cname
  rescue
    false
  end

  # before_save :ensure_gigabytes_set
  # def ensure_gigabytes_set
  #   self.number_of_free_gigabytes ||= 10
  # end

  def number_of_free_gigabytes
    if plan_id == 'pro'
      100
    elsif plan_id == 'basic'
      10
    else
      1
    end
  end

  def pusher_channel
    Digest::MD5.hexdigest ["0293jf023j9f0293jf02j3f", self.id, self.email].join(":")
  end

  def first_name
    name.to_s.split(" ")[0]
  rescue
    name
  end

  def to_s
    name || email
  end

  validates_presence_of :country, :if => :requires_country?
  def requires_country?
    stripe_customer_token.present? || stripe_card_token.present?
  end

  def maximum_number_of_sites
    if plan_id == 'pro'
      1000
    elsif plan_id == 'basic'
      10
    else
      1
    end
  end

  # Devise token_authenticatable compatibility
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_guid!
    self.guid = SecureRandom.uuid
    save!
  end
 
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
