class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.integer :user_id,         index: true
      t.integer :site_id,         index: true
      t.string  :human_name
      t.string  :name
      t.boolean :notifications,   default: true
      t.boolean :auto_response,   default: false
      t.string  :email_address
      t.string  :email_subject
      t.text    :email_body
      t.boolean :ajax_form,       default: true
      t.string  :ajax_message
      t.boolean :redirect_to_url, default: false
      t.string  :redirect_url
      t.boolean :active,          default: true

      t.timestamps null: false
    end
  end
end
