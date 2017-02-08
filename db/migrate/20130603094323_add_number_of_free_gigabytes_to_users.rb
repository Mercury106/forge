class AddNumberOfFreeGigabytesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :number_of_free_gigabytes, :integer
  end
end
