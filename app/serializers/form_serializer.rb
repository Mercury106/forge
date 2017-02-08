class FormSerializer < ApplicationSerializer
  attributes :id, :user_id, :site_id, :human_name, :name,
             :notifications, :auto_response, :email_address,
             :email_subject, :email_body, :ajax_form, :ajax_message,
             :redirect_to_url, :redirect_url, :active, :created_at,
             :fields

  has_many :form_data

  def fields
    if object.fields.present? && object.fields.any?
      object.fields.map{ |f| f.humanize.split.map(&:capitalize).join(' ') }
    else
      data = object.form_data.last.try(:data)
      data.map do |key, val|
        key.humanize.split.map(&:capitalize).join(' ')
      end if data.present?
    end
  end

  def form_data
    data = object.form_data.order(:created_at => :desc).limit(5)
  end
end