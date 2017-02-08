class SetDefaultNumberOfFreeGigabytes < ActiveRecord::Migration
  def up
    remove_column :users, :number_of_free_gigabytes
    add_column :users, :number_of_free_gigabytes, :integer, :null => false, :default => 10
  end

  def down
    remove_column :users, :number_of_free_gigabytes
    add_column :users, :number_of_free_gigabytes
  end
end
