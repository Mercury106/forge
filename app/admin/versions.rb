ActiveAdmin.register Version do
  filter :site
  
  index do
    selectable_column
    column :site
    column "File size", {sortable: 'upload_file_size'} do |site|
      number_to_human_size site.upload_file_size
    end
    column :description
    column :created_at
    actions
  end
  
  show do |version|
    attributes_table do
      row :download do
        link_to "Download this zip (#{number_to_human_size version.upload.size})", version.upload.url
      end
      row :id
      row :site
      row :created_at
      row :upload_file_size
      row :state
      row :percent_deployed
      row :deploy_slug
      row "Files" do
        file_hash = {}
        if version.file_hash
          file_hash = version.file_hash.sort_by {|filename, hash| filename.include?('.html') ? 0 : 1 }
        end
        render 'file_hash', :file_hash => file_hash
      end
    end
    active_admin_comments
  end
end
