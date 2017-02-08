require 'rails_helper'
include DropboxApiMock

describe DropboxHookWorker, type: :worker do

  before do
    @user = create(:user, dropbox_id: 111, dropbox_token: 'str')
    @site = create(:site, user: @user, dropbox_path: '/with_updated_files', dropbox_autodeploy: true)
    @version = create(:version, site: @site)

    DropboxApiMock.enable
    @worker = DropboxHookWorker.new
  end

  it 'should re-deploy the site if files were changed' do
    @worker.perform(@user.dropbox_id)
    expect(ImportFromDropboxWorker).to have_enqueued_job(@site.reload.current_version_id)
  end

  it 'should not re-deploy the site if files were not changed' do
    @site.update_column('dropbox_path', '/without_updated_files')
    @worker.perform(@user.dropbox_id)
    expect(ImportFromDropboxWorker).not_to have_enqueued_job(@site.reload.current_version_id)
  end

  it 'should not re-deploy the site if files were deleted' do
    @site.update_column('dropbox_path', '/with_deleted_files')
    @worker.perform(@user.dropbox_id)
    expect(ImportFromDropboxWorker).not_to have_enqueued_job(@site.reload.current_version_id)
  end

  it 'should keep dropbox cursor' do
    @worker.perform(@user.dropbox_id)
    expect(@site.reload.dropbox_cursor).to eq('with_updated_files')
  end
end


