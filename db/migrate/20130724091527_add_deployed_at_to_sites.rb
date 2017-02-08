class AddDeployedAtToSites < ActiveRecord::Migration
  def change
    add_column :sites, :deployed_at, :datetime
  end
end
