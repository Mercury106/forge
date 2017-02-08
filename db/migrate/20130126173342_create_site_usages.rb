class CreateSiteUsages < ActiveRecord::Migration
  def change
    create_table :site_usages do |t|
      t.references :site
      t.date :date
      t.integer :hour
      t.integer :bytes
      t.integer :cdn_bytes

      t.timestamps
    end
    add_index :site_usages, :site_id
  end
end
