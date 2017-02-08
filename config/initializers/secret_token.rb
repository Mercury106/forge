# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
if Rails.env.production? && ENV['SECRET_TOKEN'].blank?
  raise 'SECRET_TOKEN environment variable must be set!'
end

Forge::Application.config.secret_token = ENV['SECRET_TOKEN'] || "4ec363b86f6d7f90b7bc9781fbe712a3e3808a26a0edd98982hj3f9823hf4a73f9b31746321a95991351f5cf2c75d0af15d8e6a22hdcd534ab6dff17033"