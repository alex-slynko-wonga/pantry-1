Pantry::Application.routes.draw do
  resources :teams, except: [:destroy]

  get  '/login', :to => 'sessions#new', :as => :login
  post '/auth/ldap/callback', :to => 'sessions#create'
  get  '/auth/ldap/callback', :to => 'sessions#create'
  get  '/auth/failure', to: 'sessions#failure'
  get  '/logout', :to => 'sessions#destroy'

  resources :chef_nodes do
    get :search, on: :collection
  end
  resources :data_bags, only: [:index]
  resources :jobs, only: [:create, :index, :show, :update] do
    resources :job_logs, only: [:create, :index, :show, :update]
  end

  resources :packages, only: [:create, :index]
  resources :users, except: [:create, :destroy]
  root to: 'home#index'
end
