class AddSquishToSites < ActiveRecord::Migration
  def change
    add_column :sites, :squish, :boolean, :default => false
  end
end
