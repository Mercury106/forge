class HammerWebhooksController < ApplicationController
  def incoming
    @user = User.find_by(authentication_token: params[:user_token])
    @site = @user.sites.find_by(url: params[:site_url])
    ConsoleLogger.version_id = @site.current_version_id
    if params[:success] == 'true'
      ConsoleLogger.ok(
        "[hammer online] build succeeded, report is available <a \
        href='#{params[:report_url]}' target='_blank'>here</a>"
      )
      redeploy_with_new_archive
    else
      ConsoleLogger.fail(
        "[hammer online] build failed, report available <a \
        href='#{params[:report_url]}' target='_blank'>here</a>"
      )
    end
    head :ok
  end

  def redeploy_with_new_archive
    @site.current_version.update_attributes(
      hammer_archive_url: params[:archive_url]
    )
    SiteDeployWorker.perform_async(@site.id, true)
  end
end
