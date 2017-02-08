class AddDeployedAtToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :deployed_at, :timestamp
  end
end
