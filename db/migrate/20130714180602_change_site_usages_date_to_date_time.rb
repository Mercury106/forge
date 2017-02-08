class ChangeSiteUsagesDateToDateTime < ActiveRecord::Migration
  def up
    change_column :site_usages, :date, :datetime
    remove_column :site_usages, :hour
  end

  def down
    change_column :site_usages, :date, :date
    add_column :site_usages, :hour, :integer
  end
end
