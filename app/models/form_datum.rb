class FormDatum < ActiveRecord::Base
  serialize :data
  belongs_to :form
  belongs_to :user

  validates :user_id, :form_id, :data, presence: true
end
