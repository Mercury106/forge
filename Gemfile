source "https://rubygems.org"

ruby '2.2.2'

gem 'rails', '4.2.3' # '3.2.13'
gem 'activerecord-session_store', '0.1.1'

# TODO: Move to protected attributes
gem 'protected_attributes'
gem 'pg'

# Assets
gem 'sass-rails'
gem 'coffee-rails'
gem 'autoprefixer-rails'
gem 'uglifier', '>= 1.0.3'

## Attention:
## Keep your grubby mitts off these lines.
## Not all of these gems are stable and need to be preserved at
## the revision that Elliott wants.
gem 'ember-rails'
gem 'ember-data-source'
gem 'ember-source', '1.2.2'
gem 'jquery-rails'
## That is all.

gem 'authlogic'
gem 'devise', '~> 3.4.1'
gem 'devise_invitable'
gem 'cancan'
gem 'active_model_serializers'

gem 'paperclip'
gem 'carrierwave'
gem 'fog'
gem 'rubyzip'
gem 'aws-sdk', '< 2.0'
gem 'aws-s3', require: 'aws', git: 'git://github.com/bartoszkopinski/aws-s3.git'

# aws-sdk requires nokogiri < 1.6 and other gems can take something greater.
# Set the dependency manually to help bundler resolving it.
gem 'nokogiri'

gem 'heroku-api'
gem 'public_suffix'

gem 'dalli'

gem 'stripe'
gem 'valvat'
gem 'countries', :github => "hexorx/countries"
gem "country-select"

gem 'pusher'

gem 'intercom-rails'

gem 'hirefire-resource'
gem 'htmlentities'
gem 'memcachier'
gem 'puma'

gem 'ransack'
gem 'activeadmin', '~> 1.0.0.pre1'

gem 'spidr', :git => 'git://github.com/maccman/spidr.git'
gem 'dedent'
gem 'yui-compressor'

gem 'dotenv', :groups => [:development, :test]

# gem 'queue_classic', '2.3.0beta'

gem 'sidekiq', '4.0.0.pre2', require: 'sidekiq/web'
gem 'sinatra', '1.4.6', require: nil

gem 'rails-observers'
gem "d3-rails"
gem 'underscore-rails'

gem 'dropbox-api'
gem 'dropbox-sdk', '1.6.5'
gem 'oauth'
gem 'octokit' # Github API

# detect string encoding
gem "charlock_holmes_bundle_icu", "~> 0.6.9.2"

gem 'exception_notification'

group :development do
  gem 'spring'
  gem 'better_errors' #literally what it says
  gem 'binding_of_caller' #adds REPL to better_errors
  gem 'quiet_assets' #prevent asset pipeline log doesnt go to console
  gem 'guard-livereload' #adds live reload
  gem 'rack-livereload'
  gem 'meta_request' #chrome rails panel extension
  gem 'pry'
end

group :test do
  gem 'mocha', require: false
  gem 'shoulda'
  gem 'sqlite3'
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'vcr'
  gem 'webmock', require: false
  gem 'rspec-rails', require: false
  gem 'rspec-sidekiq', require: false
  gem 'test-unit'
  gem 'net-http-spy', require: false
  gem 'fakeweb'
end

group :production do
  gem 'rails_12factor', group: :production
  gem 'heroku_rails_deflate'
  gem 'rails_stdout_logging'
end
