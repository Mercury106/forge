class AddUniqueDomainMigration < ActiveRecord::Migration
  def up
    add_index :sites, :url, :unique => true
  end

  def down
    remove_index :sites, :domain
  end
end
