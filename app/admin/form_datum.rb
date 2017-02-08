ActiveAdmin.register FormDatum do
  
  filter :user
  filter :form
  
  index do
    column :id
    column :updated_at
    column :user
    column :form
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :updated_at
      row :user
      row :form
      row ('Data') do |fd|
        html = "<ul>"
        fd.data.each do |key, val|
          html += "<li><strong>#{key.humanize.split.map(&:capitalize).join(' ')}: </strong>#{val}</li>"
        end
        html += "</ul>"
        html.html_safe
      end
    end
  end

  form do |f|
    f.inputs 'Form Data details' do
      f.input :id
      f.input :updated_at
      f.input :user
      f.input :form
    end
  end

  permit_params :id, :user, :form, :created_at
end
