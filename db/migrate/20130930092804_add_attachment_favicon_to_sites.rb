class AddAttachmentFaviconToSites < ActiveRecord::Migration
  def self.up
    change_table :sites do |t|
      t.attachment :favicon
    end
  end

  def self.down
    drop_attached_file :sites, :favicon
  end
end
