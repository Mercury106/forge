require 'rails_helper'

describe Form, type: :request do
  before do
    @user = create(:user)
    @site = create(:site, user: @user)
    @forms = create_list(:form, 3, user: @user, site: @site)
    sign_in_as(@user)
  end

  describe 'Unauthorized request' do
    before do
      @user.destroy
      get '/api/forms.json'
    end

    it 'should respond with status 401' do
      expect(response.status).to eq 401
    end
  end

  describe 'GET list of forms' do
    before do
      create_list(:form, 2) # + 2 forms for another user, 5 in total
      create(:form, user: @user, active: false, site: @site)
      get '/api/forms.json', site_id: @site.id
    end

    it 'should respond with active forms of current user' do
      expect(json['forms'].map { |x| x['id'] }.sort).to eq(@forms.map(&:id).sort)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET one form settins' do
    before do
      get "/api/forms/#{@forms.first.id}.json"
    end

    it 'should respond with form' do
      expect(json['form']['id']).to eq(@forms.first.id)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'UPDATE form settins' do
    context 'with valid attributes' do
      before do
        @form = @forms.first
        @human_name = Faker::Address.country
        patch "/api/forms/#{@form.id}.json",
              form: { human_name: @human_name }
      end

      it 'should update form settins' do
        expect(Form.find(@form.id).human_name).to eq(@human_name)
      end

      it 'should respond with status 200' do
        expect(response.status).to eq 200
      end
    end
    context 'with invalid attributes' do
      before do
        @form = @forms.first
        @human_name = ''
        patch "/api/forms/#{@form.id}.json",
              form: { human_name: @human_name }
      end

      it 'should not update form settins' do
        expect(Form.find(@form.id).human_name).to eq(@form.human_name)
      end

      it 'should respond with status 422' do
        expect(response.status).to eq 422
      end
    end
  end

  describe 'DELETE (hide) form settins' do
    before do
      @form = @forms.first
      delete "/api/forms/#{@form.id}.json"
    end

    it 'should mark form as inactive' do
      expect(Form.find(@form.id).active).to eq(false)
    end
  end
end
