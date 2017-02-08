class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.references :site

      t.timestamps
    end
    add_index :versions, :site_id
  end
end
