require 'rails_helper'

describe DropboxController, type: :request do

  before do
     @user = create(:user, dropbox_id: 111)
  end

  it 'should respond with challenge message' do
    @challenge = rand
    post '/dropbox-webhook', challenge: @challenge
    expect(response.body).to eq(@challenge.to_s)
  end

  it 'should enqueue a job to check if site should be re-deployed' do
    post '/dropbox-webhook', delta: { users: [222, @user.dropbox_id] }
    expect(DropboxHookWorker).to have_enqueued_job(@user.dropbox_id.to_s)
  end 

  # TODO find another way to test it. This doesn't work because of rspec-sidekiq gem.
  # it 'should not re-deploy the site if time past less than 5 minutes' do
  #   post '/dropbox-webhook', delta: "{\"users\": [#{@user.dropbox_id}]}"
  #   post '/dropbox-webhook', delta: "{\"users\": [#{@user.dropbox_id}]}"
  #   expect(DropboxHookWorker.jobs.size).to eq(1)
  # end
end
