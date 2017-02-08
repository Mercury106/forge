class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :text
      t.integer :user_id
      t.integer :site_id
      t.string :action

      t.timestamps
    end
  end
end
