Forge::Application.configure do
  config.eager_load = true
  
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Super compress and cache assets on production
  if Rails.env.production?
    config.static_cache_control  = "public, max-age=31536000"
    config.assets.js_compressor  = :uglifier
    config.assets.css_compressor = :yui
    config.assets.version        = "1.2"
  end

  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['AWS_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }

  # Only compile a missing precompiled asset on production
  config.assets.compile = Rails.env.production?

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL in production, use
  # Strict-Transport-Security, and use secure cookies.
  config.force_ssl = Rails.env.production?

  # See everything in the log (default is :info)
  config.log_level = :info

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  config.cache_store = :dalli_store
  config.assets.cache_store = :dalli_store
  config.assets.configure {|env|
    env.cache = ActiveSupport::Cache.lookup_store(:dalli_store)
  }


  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( teaser/all.js teaser/all.css teaser/*.* )
  
  config.assets.precompile += %w(turbojs/turbo.js) if Rails.env.production?
  config.assets.precompile += %w(teaser.css teaser.js)
  config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif *.ico]
  config.assets.precompile += %w(teaser/apple-touch-icon.png)
  config.assets.paths << Rails.root.join("app/assets/images/teaser").to_s

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.ember.variant = :production

  config.action_mailer.default_url_options = { :host => "getforge.com" }

  config.asset_host = ENV['ASSET_HOST']
end
