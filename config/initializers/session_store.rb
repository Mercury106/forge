# Be sure to restart your server when you modify this file.

# Forge::Application.config.session_store :cookie_store, key: '_forge_session', domain: :all

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Forge::Application.config.session_store :active_record_store

module ActiveRecord
  module SessionStore
    # The default Active Record class.
    class Session < ActiveRecord::Base
      attr_accessible :session_id, :data
    end
  end
end