class AddLatestScopedVersionIdToSites < ActiveRecord::Migration
  def up
    add_column :sites, :latest_scoped_version_id, :integer
    add_column :versions, :scoped_id, :integer
    add_index :versions, [:site_id, :scoped_id]
    
    Site.all.each do |site|
      v = 0
      site.versions.reverse.each do |version|
        v += 1
        version.scoped_id = v
        version.save()
      end
      site.latest_scoped_version_id = v
      site.save()
    end
  end
  
  def down
    remove_column :sites, :latest_scoped_version_id, :integer
    remove_column :versions, :scoped_id, :integer
  end
end