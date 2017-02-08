ActiveAdmin.register Site do
  
  filter :url
  
  action_item('Deploy', only: show) do
    link_to('Deploy', action: :deploy)
  end
  
  index do
    selectable_column
    column :url do |site|
      link_to site.url, admin_site_path(site)
    end
    column :user do |site|
      link_to site.user.name || site.user.email, admin_site_path(site)
    end
    column :updated_at
    column :squish
    actions
  end
  
  show do |site|
    attributes_table do
      row :id
      row :url do |site|
        link_to site.url, "http://#{site.url}", :target => "_blank"
      end
      row :user do |site|
        link_to site.user.name || site.user.email, admin_user_path(site.user)
      end
      row :created_at
      row :versions do |site|
        render 'versions', :versions => site.versions
      end
    end
  end

  member_action :deploy do
    @site = Site.find(params[:id])
    @site.deploy()
    redirect_to :back, :notice => "Deployed #{@site.url}."
  end

  form do |f|
    f.inputs 'Site details' do
      f.input :user_id,
              label: 'User',
              as: :select,
              collection: User.select(:id, :name, :email).map { |u| ["#{u.name} (#{u.email}) {id:#{u.id}}", u.id] }
      f.input :url
      f.input :current_version_id,
              label: 'Current version',
              as: :select,
              collection: Version.where(site_id: f.object.id).map { |v|
                ["Version\##{v.id} - #{v.created_at.strftime('%d/%m/%y %l:%M %p')}", v.id]
              }
      f.input :dropbox_autodeploy
      f.input :dropbox_path
      f.input :github_autodeploy
      f.input :github_path
      f.input :github_branch
      # f.input :current_deploy_slug
      f.actions
    end
  end
  
end
