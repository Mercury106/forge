class AddCurrentVersionIdToSites < ActiveRecord::Migration
  def change
    add_column :sites, :current_version_id, :integer
  end
end
