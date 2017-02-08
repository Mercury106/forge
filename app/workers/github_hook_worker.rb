class GithubHookWorker
  include Sidekiq::Worker

  def self.create_hook(site_id)
    GithubHookWorker.perform_async(site_id, 'add')
  end

  def self.destroy_hook(site_id)
    GithubHookWorker.perform_async(site_id, 'remove')
  end

  def perform(site_id, action)
    site = Site.find(site_id)
    client = Octokit::Client.new(access_token: site.user.github_token)
    case action
    when 'add'
      remove_hook(client, site) if site.github_webhook_id.present?
      site.update_columns(
        github_webhook_id: add_hook(client, site)[:id],
        github_autodeploy: true
      )
    when 'remove'
      remove_hook(client, site) if site.github_webhook_id.present?
      site.update_columns(
        github_webhook_id: nil,
        github_autodeploy: false
      )
    end
  end

  private

  def github_repo(github_path)
    chains = github_path.split('/')
    [chains[0], chains[1]].join('/')
  end

  def hook_url(site)
    "#{ENV['PRODUCTION_DOMAIN']}/webhook?type=redeploy&url=#{site.url}&token=#{site.user.authentication_token}"
  end

  def add_hook(client, site)
    client.create_hook(
      github_repo(site.github_path),
      'web',
      {
        url: hook_url(site),
        content_type: 'json'
      },
      {
        events: ['push'],
        active: true
      }
    )
  end

  def remove_hook(client, site)
    client.remove_hook(github_repo(site.github_path), site.github_webhook_id)
  end
end
