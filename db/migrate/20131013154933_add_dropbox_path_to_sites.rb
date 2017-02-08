class AddDropboxPathToSites < ActiveRecord::Migration
  def change
    add_column :sites, :dropbox_path, :string
  end
end
