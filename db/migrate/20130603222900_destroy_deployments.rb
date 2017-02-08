class DestroyDeployments < ActiveRecord::Migration
  def up
    drop_table :deployments
  end

  def down
    create_table :deployments do |t|
      t.integer :site_id
      t.string :slug
      t.string :url
      t.integer :version_id

      t.timestamps
    end
  end
end
