class TurbojsController < ApplicationController
  def asset
    key = "turbojs:asset:#{params[:version]}"
    text = Rails.cache.read(key)

    if !text
      file_path = File.join(Rails.root, 'app', 'assets', 'javascripts', 'turbojs', 'turbo.js')
      text = open(file_path).read
      Rails.cache.write(key, text, :expires_in => 6.hours)
    end

    render :js => text
  end
end