Pantry::Application.routes.draw do
  resources :teams, except: [:destroy]

  get   '/login', :to => 'sessions#new', :as => :login
  match '/auth/failure', :to => 'sessions#failure'
  match '/auth/:provider/callback', :to => 'sessions#create'
  get   '/logout', :to => 'sessions#destroy'

  resources :chef_nodes do
    get :search, on: :collection
  end
  resources :data_bags, only: [:index]
  resources :jobs, only: [:create, :index, :show, :update] do
    resources :job_logs, only: [:create, :index, :show, :update]
  end
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  resources :packages, only: [:create, :index]
  resources :users, except: [:create, :destroy]
  root to: 'home#index'
end
