class VersionSerializer < ApplicationSerializer
  
  # cached
  
  attributes :description, :id, :scoped_id, :upload_file_size, :diff, :percent_deployed, :site_id, :created_at, :scoped_id

  def diff
    object.truncated_diff
  end

end