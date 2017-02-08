class AddUploadToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :upload, :string
  end
end
