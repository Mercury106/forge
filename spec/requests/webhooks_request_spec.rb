require 'rails_helper'

describe WebHooksController, type: :request do
  before do
    @user = create(:user)
    @site = create(:site, user: @user)
    @version = create(:version, site: @site)
    @site.update_attribute('current_version_id', @version.id)
    @parameters = { type: 'redeploy',
                    url: @site.url,
                    token: @user.authentication_token,
                    delay: 5 }
  end

  describe 'POST request with correct parameters' do
    it 'should create new version' do
      expect do
        post '/webhook', @parameters
      end.to change(Version, :count).by(1)
    end

    it 'should respond with correct text' do
      post '/webhook', @parameters
      expect(response.body).to eq('Your request was successfully received.')
    end

    it 'should enqueue delayed job to deploy a site' do
      post '/webhook', @parameters
      expect(SiteDeployWorker).to have_enqueued_job(@site.id, true)
    end

    it 'should enqueue job to deploy a site from Dropbox' do
      @site.update_column('dropbox_path', '/foo')
      post '/webhook', @parameters
      expect(ImportFromDropboxWorker).to have_enqueued_job(@site.reload.current_version_id)
    end

    it 'should enqueue job to deploy a site from Github' do
      @site.update_column('github_path', 'foo')
      post '/webhook', @parameters
      expect(ImportFromGithubWorker).to have_enqueued_job(@site.reload.current_version_id)
    end
  end

  describe 'POST request with incorrect parameters' do
    before do
      @parameters[[:token, :url].sample] = nil
    end

    it 'should not create new version' do
      expect do
        post '/webhook', @parameters
      end.to change(Version, :count).by(0)
    end

    it 'should not enqueue job to deploy a site' do
      post '/webhook', @parameters
      expect(SiteDeployWorker).not_to have_enqueued_job(@site.id)
    end
  end
end
