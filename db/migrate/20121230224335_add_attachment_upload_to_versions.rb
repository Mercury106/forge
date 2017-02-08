class AddAttachmentUploadToVersions < ActiveRecord::Migration
  def self.up
    change_table :versions do |t|
      t.attachment :upload
    end
  end

  def self.down
    drop_attached_file :versions, :upload
  end
end
