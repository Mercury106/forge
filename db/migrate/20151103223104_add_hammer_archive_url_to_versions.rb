class AddHammerArchiveUrlToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :hammer_archive_url, :string
  end
end
