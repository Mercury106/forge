class AddFileHashToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :file_hash, :text
  end
end
