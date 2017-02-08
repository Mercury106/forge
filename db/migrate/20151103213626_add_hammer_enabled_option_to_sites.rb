class AddHammerEnabledOptionToSites < ActiveRecord::Migration
  def change
    add_column :sites, :hammer_enabled, :boolean, default: false
  end
end
