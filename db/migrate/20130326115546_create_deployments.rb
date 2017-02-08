class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.integer :site_id
      t.string :slug
      t.string :url
      t.integer :version_id

      t.timestamps
    end
  end
end
