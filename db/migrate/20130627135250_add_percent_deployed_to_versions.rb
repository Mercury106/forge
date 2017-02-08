class AddPercentDeployedToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :percent_deployed, :integer, :default => 0
  end
end
