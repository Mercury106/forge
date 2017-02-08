class Webhook < ActiveRecord::Base
  attr_accessible :data, :live, :stripe_id
  
  serialize :data
end
