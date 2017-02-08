class AddDropboxCursorAndGithubWebhookIdToSites < ActiveRecord::Migration
  def change
    add_column :sites, :dropbox_autodeploy, :boolean
    add_column :sites, :dropbox_cursor,     :string
    add_column :sites, :github_autodeploy,  :boolean
    add_column :sites, :github_webhook_id,  :integer
  end
end
