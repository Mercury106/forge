ActiveAdmin.register WebhookTrigger do
  
  filter :user, collection: proc{ User.select(:id, :name).limit(1000) }
  filter :site, collection: proc{ Site.select(:id, :url).limit(1000) }
  filter :event,
         as: :select,
         collection: YAML.load_file('config/webhooks.yml')['events'].map { |e, val|
           [e.humanize.titleize, e]
         }
  
  index do
    column :id
    column :updated_at
    column :user
    column :site
    column :http_method
    column :url
    column ('Event'){ |x| x.event.humanize.titleize }
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :updated_at
      row :user
      row :site
      row :http_method
      row :url
      row ('Event'){ |x| x.event.humanize.titleize }
    end
  end

  form do |f|
    f.inputs 'Webhook Trigger details' do
      f.input :user_id,
              label: 'User',
              as: :select,
              collection: User.select(:id, :name, :email).map { |u| ["#{u.name} (#{u.email}) {id:#{u.id}}", u.id] }
      f.input :site_id,
              label: 'Site',
              as: :select,
              collection: Site.select(:id, :url).map { |s| [s.url, s.id] }
      f.input :event,
              as: :select,
              collection: YAML.load_file('config/webhooks.yml')['events'].map { |e, val|
                [e.humanize.titleize, e]
              }
      f.input :http_method, as: :select, collection: ['GET', 'POST']
      f.input :url
      f.input :parameters,
              hint: 'Use next format for parameters: "key=value", each pair start from new line.\
                    If you\'re creating a hook for form submission, you can also use form variables\
                    like name={{first_name}}. List of available variables you can see in form fields row.',
              input_html: { placeholder: "sender=forge\nyear=#{Date.today.year}" }
      f.actions
    end
  end

  permit_params :user_id, :site_id, :url, :http_method, :event,
                :parameters
end
