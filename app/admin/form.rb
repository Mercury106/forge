ActiveAdmin.register Form do
  
  filter :user, collection: proc{ User.select(:id, :name).limit(1000) }
  filter :site, collection: proc{ Site.select(:id, :url).limit(1000) }
  
  index do
    column :id
    column :updated_at
    column :user
    column :site
    column :notifications
    column :auto_response
    column :ajax_form
    column :redirect_to_url
    column :active
    actions
  end
  
  show do |site|
    attributes_table do
      row :user
      row :site
      row :human_name
      row :name
      row :notifications
      row :auto_response
      row :email_address
      row :email_subject
      row :email_body
      row :ajax_form
      row :ajax_message
      row :redirect_to_url
      row :redirect_url
      row :active
      row :fields
    end
  end

  permit_params :user, :site, :human_name, :name, :notifications,
                :auto_response, :email_address, :email_subject,
                :email_body, :ajax_form, :ajax_message,
                :redirect_to_url, :redirect_url, :active
end
