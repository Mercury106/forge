class Domain < ActiveRecord::Base
  attr_accessible :url, :user
  belongs_to :user
end
