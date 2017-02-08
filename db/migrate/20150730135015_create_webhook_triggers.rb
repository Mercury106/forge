class CreateWebhookTriggers < ActiveRecord::Migration
  def change
    create_table :webhook_triggers do |t|
      t.integer :user_id
      t.integer :site_id
      t.string :event
      t.string :url
      t.string :http_method
      t.text :parameters

      t.timestamps null: false
    end
  end
end
