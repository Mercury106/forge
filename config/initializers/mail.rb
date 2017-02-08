if ENV['SENDGRID_USERNAME'] && ENV['SENDGRID_PASSWORD']
  ActionMailer::Base.smtp_settings = {
    :address              => 'smtp.sendgrid.net',
    :port                 => '587',
    :authentication       => :plain,
    :user_name            => ENV['SENDGRID_USERNAME'],
    :password             => ENV['SENDGRID_PASSWORD'],
    :domain               => 'heroku.com',
    :enable_starttls_auto => true
  }
end

if ENV['MAILER_DEFAULT_URL']
  require 'uri'

  default_uri = URI.parse(ENV['MAILER_DEFAULT_URL'])
  options = { protocol: default_uri.scheme, host: default_uri.host }
  Forge::Application.config.action_mailer.default_url_options = options
end
