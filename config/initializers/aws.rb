if ENV['AWS_BUCKET']
  AWS.config bucket:               ENV['AWS_BUCKET'],
             access_key_id:        ENV['AWS_ACCESS_KEY_ID'],
             secret_access_key:    ENV['AWS_SECRET_ACCESS_KEY'],
             region:               ENV['AWS_REGION'],
             s3_signature_version: :v4

  Forge::Application.config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket            => ENV['AWS_BUCKET'],
      :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      region: 'eu-central-1',
      s3_signature_version: :v4
    }
  }
end
