class CreateFormData < ActiveRecord::Migration
  def change
    create_table :form_data do |t|
      t.integer :user_id, index: true
      t.integer :form_id, index: true
      t.text :data

      t.timestamps null: false
    end
  end
end
