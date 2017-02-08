class UploadController < ApplicationController

  # This line was removed from both hashes since we're not making a redirect.
  # success_action_redirect => ""
  
  # Create the document in rails, then send json back to our javascript to populate the form that will be
  # going to amazon.
  def policy
    @key = "/uploads/#{current_user.id}/#{(rand * 1000000).to_i}.zip"
    render :json => {
      :AWSAccessKeyId => ENV['AWS_ACCESS_KEY_ID'],
      :policy => s3_upload_policy_document, 
      :signature => s3_upload_signature, 
      :key => @key, 
      :acl => 'public-read'
    }
  end
 
private
  
  # generate the policy document that amazon is expecting.
  def s3_upload_policy_document

    megs = ENV['MAX_SIZE_IN_MEGABYTES'].to_f || 100
    max_size = megs.megabytes.to_i

    return @policy if @policy
    ret = {
      "expiration" => 30.minutes.from_now.utc.xmlschema,
      "conditions" =>  [ 
        {"bucket" =>  ENV['AWS_BUCKET']}, 
        ["starts-with", "$key", @key],
        {"acl" => "public-read"},
        ["content-length-range", 0, max_size]
      ]
    }
    @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
  end

  # sign our request by Base64 encoding the policy document.
  def s3_upload_signature
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), ENV['AWS_SECRET_ACCESS_KEY'], s3_upload_policy_document)).gsub("\n","")
  end

end