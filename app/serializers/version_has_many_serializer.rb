# This is used inside the serialized Site, bundled into a hasMany
# The full record can be requested separately.

class VersionHasManySerializer < ApplicationSerializer
  
  # cached
  
  attributes :description, :id, :upload_file_size, :diff, :percent_deployed, :site_id, :created_at, :scoped_id
  
end