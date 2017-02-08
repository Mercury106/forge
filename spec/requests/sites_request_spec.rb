require 'rails_helper'

describe DropboxController, type: :request do
  before do
    @user = create(:user)
    @site = create(:site, user: @user, github_path: '/sample_repo')
    sign_in_as(@user)
  end

  describe 'UPDATE with github autodeploy enabled' do
    before do
      patch "/api/sites/#{@site.id}", site: { github_autodeploy: true }
    end

    it 'should enqueue a GithubHookWorker job to create a webhook' do
      expect(GithubHookWorker).to have_enqueued_job(@site.id, 'add')
    end
    
  end

  describe 'UPDATE with github autodeploy disabled' do
    before do
      @site.update_column('github_autodeploy', true)
      patch "/api/sites/#{@site.id}", site: { github_autodeploy: false }
    end
    it 'should enqueue a GithubHookWorker job to remove a webhook' do
      expect(GithubHookWorker).to have_enqueued_job(@site.id, 'remove')
    end
  end
end
