class MoveDeploySlugFromSitesToVersions < ActiveRecord::Migration
  def change
    remove_column :sites, :current_deploy_slug, :string
    add_column :versions, :deploy_slug, :string
  end
end
