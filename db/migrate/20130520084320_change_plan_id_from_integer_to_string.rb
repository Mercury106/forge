class ChangePlanIdFromIntegerToString < ActiveRecord::Migration
  def up
    add_column :users, :plan_id, :string
  end

  def down
    remove_column :users, :plan_id, :integer
  end
end
