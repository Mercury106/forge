require 'rails_helper'

describe FormDatum, type: :request do
  before do
    @user = create(:user)
    @site = create(:site, user: @user)
    @form = create(:form, user: @user, site: @site)
    @form_data = create_list(:form_datum, 2, user: @user, form: @form)

    sign_in_as(@user)
  end

  describe 'Unauthorized request' do
    before do
      @user.destroy
      get '/api/form-data.json'
    end

    it 'should respond with status 401' do
      expect(response.status).to eq 401
    end
  end

  describe 'GET list of form data' do
    before do
      create_list(:form_datum, 2) # + 2 for another user, 4 in total
      get '/api/form-data.json'
    end

    it 'should respond with form data of current user' do
      expect(json['form_data'].map { |x| x['id'] }.sort).to eq(@form_data.map(&:id).sort)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET one form data' do
    before do
      get "/api/form-data/#{@form_data.first.id}.json"
    end

    it 'should respond with form data' do
      expect(json['form_datum']['id']).to eq(@form_data.first.id)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'CREATE form data' do
    before do
      post '/api/form-data/',
           {
             @form.name => { email: 'admin@superuser.com' },
             forge_form_name: @form.name
           },
           HTTP_REFERER: "http://#{@site.url}"
    end

    it 'should create new form_data' do
      expect(@form.form_data.count).to eq(3)
    end

    it 'should respond with status 200' do
      expect(response.status).to eq 200
    end

    it 'should return CORS headers' do
      expect(response.headers.keys).to include(
        'Access-Control-Allow-Origin',
        'Access-Control-Allow-Methods',
        'Access-Control-Allow-Headers',
        'Access-Control-Max-Age'
      )
    end
  end

  describe 'DELETE form data' do
    before do
      @form_datum = @form_data.first
      delete "/api/form-data/#{@form_datum.id}.json"
    end

    it 'should delete form data' do
      expect(FormDatum.where(id: @form_datum.id).count).to eq(0)
    end
  end

  describe 'OPTIONS request to /api/form-data' do
    before do
      options '/api/form-data'
    end

    it 'should return CORS headers' do
      expect(response.headers.keys).to include(
        'Access-Control-Allow-Origin',
        'Access-Control-Allow-Methods',
        'Access-Control-Allow-Headers',
        'Access-Control-Max-Age'
      )
    end
    
  end
end
