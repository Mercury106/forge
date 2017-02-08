class AddPreviousVersionIdToSites < ActiveRecord::Migration
  def change
    add_column :sites, :previous_version_id, :integer
  end
end
