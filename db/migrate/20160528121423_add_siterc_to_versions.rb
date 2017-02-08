class AddSitercToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :siterc, :text
  end
end
