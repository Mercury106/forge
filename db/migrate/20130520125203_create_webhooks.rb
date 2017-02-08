class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.text :data
      t.string :stripe_id
      t.boolean :live

      t.timestamps
    end
  end
end
