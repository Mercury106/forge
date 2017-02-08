class RemoveCdnBytesFromSiteUsages < ActiveRecord::Migration
  def up
    remove_column :site_usages, :cdn_bytes
  end

  def down
    add_column :site_usages, :cdn_bytes, :integer
  end
end
