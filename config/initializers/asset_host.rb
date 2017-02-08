if ENV['ASSET_HOST']
  Forge::Application.configure do
    # Enable serving of images, stylesheets, and JavaScripts from an asset server
    config.asset_host = ENV['ASSET_HOST']
    config.action_controller.asset_host = ENV['ASSET_HOST']
    config.action_mailer.asset_host     = ENV['ASSET_HOST']
  end
end
