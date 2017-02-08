class AddDiffToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :diff, :text
  end
end
