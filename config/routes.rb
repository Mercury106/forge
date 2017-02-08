Forge::Application.routes.draw do
  ## For pushState URLs. iFrames stop us doing this so far.
  # match "/*path", :to => "public#index"
  root to: 'public#index'

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "/assets/turbojs/(:version)/turbo.js", :to => "turbojs#asset"
  get '/turbo.js', :to => "turbojs#asset"

  post "/", :to => "upload#err"

  get "/deployed.:format",       :to => "api#deployed"
  get "/deployed_sites.:format", :to => 'api#deployed_sites'
  get '/site_meta', to: 'api#site_meta'

  ## API

  # For heroku, /cdn/-based routes
  get "cdn/:id/(:filename)", :to => 'sites#public', :as => :site_cdn

  ## User panel

  # resources :users, defaults: {format: :json}
  scope(:path => '/api') do
    get "/github", :to => "github#index"
    resources :invoices, defaults: {format: :json}
    get 'users/check', to: 'users#check_user'
    resources :users, defaults: {format: :json}
    resources :site_users, defaults: {format: :json}
    resources :site_usages, defaults: {format: :json}
    resources :versions, defaults: {format: :json} do
      member do
        get :download
      end
    end
    resources :sites, defaults: {format: :json} do
      member do
        get :favicon
      end
      collection do
        get :bootstrap, {defaults: {format: :json}}
      end
    end
    resources :sessions

    resources :forms, only: [:index, :show, :update, :destroy] do
      resources :form_data, only: [:index, :show]
      get 'csv_data', to: 'forms#csv_data'
      # get 'form_data', to: 'forms#form_data'
    end

    resources :forms, only: [:index, :show, :update, :destroy]
    resources :form_data, only: [:index, :show]
    resources :webhook_triggers, only: [:index, :create, :update, :destroy]


    match '/form-data', to: 'form_data#cors', via: :options
    resources :form_data, path: 'form-data'

    # CLI routes
    scope :cli do
      get 'sites', to: 'cli#sites'
      post 'login', to: 'cli#login'
      post 'create', to: 'cli#create'
      post 'deploy', to: 'cli#deploy'
    end
  end
  resources :sessions

  get "/upload/policy", :to => "upload#policy"

  resource :account do
    get :change_card
    get :invoices
  end

  match "/webhook",         to: "web_hooks#incoming", via: [:get, :post]
  match "/dropbox-webhook", to: "dropbox#incoming",   via: [:get, :post]
  match "/hammer-webhook", to: "hammer_webhooks#incoming",   via: [:get, :post]

  devise_for :users, :controllers => {
    :invitations => 'users/invitations',
    :registrations => 'devise/registrations',
    :sessions => 'sessions',
    :passwords => 'devise/forge_passwords'
  }

  # Dropbox
  get '/oauth/dropbox', :to => "oauth#dropbox"
  get "/oauth/github", :to => "oauth#github"

  get "/tests", :to => "application#tests"

  # Testing routes.
  get '/signout', :to => "sessions#destroy"

  get "/unfinished", :to => "public#unfinished"
  get "/terms", :to => "public#terms"
  get "/showcase", :to => "public#showcase"
  get "/:page", :to => "public#page"
  get "/blog/:page", :to => "public#blog"
  get "/signup", :to => "public#signup"
end
