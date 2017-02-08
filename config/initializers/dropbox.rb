Dropbox::API::Config.app_key    = ENV['DROPBOX_APP_TOKEN']
Dropbox::API::Config.app_secret = ENV['DROPBOX_APP_SECRET']
Dropbox::API::Config.mode       = Rails.env.test? ? 'sandbox' : 'dropbox' # if you have a single-directory app or "dropbox" if it has access to the whole dropbox