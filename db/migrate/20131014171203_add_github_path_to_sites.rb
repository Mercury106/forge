class AddGithubPathToSites < ActiveRecord::Migration
  def change
    add_column :sites, :github_path, :string
  end
end
