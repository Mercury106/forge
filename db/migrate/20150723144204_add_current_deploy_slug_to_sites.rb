class AddCurrentDeploySlugToSites < ActiveRecord::Migration
  def change
    add_column :sites, :current_deploy_slug, :string
  end
end
