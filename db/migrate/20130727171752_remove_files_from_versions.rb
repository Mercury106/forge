class RemoveFilesFromVersions < ActiveRecord::Migration
  def change
    remove_column :versions, :files
  end
end
