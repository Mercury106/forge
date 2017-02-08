require 'rails_helper'
include GithubApiMock

describe GithubHookWorker, type: :worker do
  before do
    @user = create(:user, github_token: 'str')
    @site = create(:site, user: @user, github_path: '/build', github_autodeploy: true)
    @version = create(:version, site: @site)

    @hook_id = rand(1000)
    GithubApiMock.enable(@hook_id)
    @worker = GithubHookWorker.new
  end

  context 'on create github webhook' do
    before do
      @worker.perform(@site.id, 'add')
    end

    it 'should create new hook' do
      expect(@site.reload.github_webhook_id).to eq(@hook_id)
    end

    it 'should delete existing hook before adding new one' do
      expect(@worker).to receive(:remove_hook)
      @worker.perform(@site.id, 'add')
    end
  end

  context 'on remove github webhook' do
    before do
      @site.update_column('github_webhook_id', @hook_id)
    end
    it 'should delete github hook' do
      expect(@worker).to receive(:remove_hook)
      @worker.perform(@site.id, 'remove')
    end
  end
end


