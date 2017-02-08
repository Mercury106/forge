require 'rails_helper'

describe WebhookTrigger, type: :request do
  before do
    @user = create(:user)
    @wts = create_list(:webhook_trigger, 3, user: @user)
    sign_in_as(@user)
  end

  describe 'Unauthorized request' do
    before do
      @user.destroy
      get '/api/webhook_triggers.json'
    end

    it 'should respond with status 401' do
      expect(response.status).to eq 401
    end
  end

  describe 'GET list of webhook triggers' do
    before do
      create_list(:webhook_trigger, 2) # + 2 webhooks for another user, 5 in total
      get '/api/webhook_triggers.json'
    end

    it 'should respond with webhook triggers of current user' do
      expect(json['webhook_triggers'].map { |x| x['id'] }.sort).to eq(@wts.map(&:id).sort)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'UPDATE webhook trigger' do
    context 'with valid attributes' do
      before do
        @wt = @wts.first
        @http_method = @wt.http_method == 'GET' ? 'POST' : 'GET'
        patch "/api/webhook_triggers/#{@wt.id}.json",
              webhook_trigger: { http_method: @http_method }
      end

      it 'should update webhook trigger' do
        expect(WebhookTrigger.find(@wt.id).http_method).to eq(@http_method)
      end

      it 'should respond with status 200' do
        expect(response.status).to eq 200
      end
    end

    context 'with invalid attributes' do
      before do
        @wt = @wts.first
        patch "/api/webhook_triggers/#{@wt.id}.json",
              webhook_trigger: { http_method: '' }
      end

      it 'should not update webhook trigger' do
        expect(WebhookTrigger.find(@wt.id).http_method).to eq(@wt.http_method)
      end

      it 'should respond with status 422' do
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE webhook trigger' do
    before do
      @wt = @wts.first
      delete "/api/webhook_triggers/#{@wt.id}.json"
    end

    it 'should delete webhook trigger' do
      expect(WebhookTrigger.where(id: @wt.id).count).to eq(0)
    end
  end
end
