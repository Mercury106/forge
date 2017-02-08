class SiteSerializer < ApplicationSerializer

  #cached

  attributes :id, :url, :current_version_id, :squish, :user_id, :force_deploy,
             :bandwidth, :updated_at, :site_user_ids, :dropbox_path,
             :github_path, :github_branch, :current_deploy_slug, :deploy_token,
             :dropbox_autodeploy, :dropbox_cursor, :github_autodeploy,
             :github_webhook_id, :webhook_triggers, :hammer_enabled
  def versions
    object.versions.limit(20)
  end

  def github_path
    object.github_path
  end

  def deploy_token
    object.user.authentication_token
  end

  def current_deploy_slug
    object.current_version.try(:deploy_slug)
  end

  has_many :versions, :serializer => VersionHasManySerializer
  has_many :webhook_triggers


  def webhook_triggers
    object.webhook_triggers
  end


  def bandwidth
    Rails.cache.fetch("site:#{object.id}", :expires_in => 1.hour) do
      this_month = Date.today.beginning_of_month

      months = []
      6.times do |months_ago|
        month = Date.today - months_ago.months
        month_name = Date::MONTHNAMES[month.month]
        bandwidth_in_month = object.bandwidth_in_month(Date.today - months_ago.months)

        month_name = "#{month_name} #{month.year}"
        months << {month: month_name, bandwidth: bandwidth_in_month}
      end

      {
        :month            => object.bandwidth_since(1.month.ago),
        :this_month       => object.bandwidth_since(Date.today.beginning_of_month),
        :week             => object.bandwidth_since(Date.today.beginning_of_week),
        :today            => object.bandwidth_since(Date.today.beginning_of_day),
        :previous_months  => months
      }
    end
  end

end