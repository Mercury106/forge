class AddFilesToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :files, :text
  end
end
