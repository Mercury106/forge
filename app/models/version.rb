require "open-uri"

class Version < ActiveRecord::Base
  include Version::Diff
  include Version::ScopedId
  include Version::Sockets unless Rails.env.test?
  include Version::DropboxDeployer
  include Version::GithubDeployer

  serialize :files

  before_save :import_from_remote_upload_url
  before_destroy :check_whether_site_is_currently_deployed

  belongs_to :site, :touch => true
  has_attached_file :upload

  validates_attachment_size :upload, :less_than => 2000.megabytes
  validates_attachment_content_type :upload, :content_type => ['application/zip', 'application/octet-stream', 'application/x-gzip']

  attr_accessible :upload, :description, :state, :remote_upload_url, :site_id,
                  :percent_deployed, :size, :created_at, :scoped_id,
                  :hammer_archive_url
                  
  attr_accessor :remote_upload_url, :size

  def drag_and_drop?
    site.dropbox_path.blank? && site.github_path.blank?
  end

  def truncated_diff
    if original_diff = diff
      new_diff = {}
      original_diff.keys.each do |key|
        new_diff[(key.to_s+"_total").to_sym] = original_diff[key].length
        new_diff[key] = original_diff[key].first(20)
      end
      new_diff
    end
  end

  def import_from_remote_upload_url
    if self.remote_upload_url
      self.upload = open(self.remote_upload_url)
      self.remote_upload_url = nil
    end
  end
  
  def check_whether_site_is_currently_deployed
    # TODO: Check state. Live = safe.
    # reload()
    # site.reload() if site
    if site && site.current_version_id == self.id && !site.destroyed?
      self.errors.add :base, "You cannot delete this version because it is currently live."
      return false
    end
  end
end