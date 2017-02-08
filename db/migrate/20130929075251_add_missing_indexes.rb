class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :sites, :current_version_id
    add_index :news_items, :site_id
    add_index :news_items, :user_id
    add_index :domains, :user_id
    add_index :users, [:invited_by_id, :invited_by_type]
  end
end