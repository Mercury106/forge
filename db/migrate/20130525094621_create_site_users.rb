class CreateSiteUsers < ActiveRecord::Migration
  def up
    create_table :site_users do |t|
      t.integer :site_id
      t.integer :user_id

      t.timestamps
    end
    
    add_index :site_users, :site_id
    add_index :site_users, :user_id
    
    # Ensure all sites have site_users
    Site.all.each do |site|
      site.save
    end
    
  end
  
  def down
    drop_table :site_users
  end
  
end
