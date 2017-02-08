class Form < ActiveRecord::Base
  serialize :fields
  before_save :update_name
  belongs_to :user
  belongs_to :site
  has_many :form_data, dependent: :destroy

  validates :user_id, :human_name, presence: true
  validates :human_name, :name, :email_address, :email_subject,
            :ajax_message, :redirect_url,
            length: { maximum: 255 }
  validates :redirect_url, presence: true, if: :redirect_to_url
  validates :email_address, :email_subject, :email_body,
            presence: true, if: :auto_response

  scope :active, -> { where(active: true) }

  private

  def update_name
    self.name = human_name.parameterize.underscore
  end
end
