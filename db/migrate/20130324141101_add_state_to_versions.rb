class AddStateToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :state, :string
  end
end
