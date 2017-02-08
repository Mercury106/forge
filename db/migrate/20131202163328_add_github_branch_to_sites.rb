class AddGithubBranchToSites < ActiveRecord::Migration
  def change
    add_column :sites, :github_branch, :string
  end
end
