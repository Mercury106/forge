class ChangeBytesToBigintInSiteUsages < ActiveRecord::Migration
  def up
    change_column :site_usages, :bytes, :integer, :limit => 8
  end

  def down
    change_column :site_usages, :bytes, :integer
  end
end
