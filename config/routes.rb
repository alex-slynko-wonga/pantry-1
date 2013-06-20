Pantry::Application.routes.draw do
  resources :chef_nodes do
    get :search, on: :collection
  end

  resources :data_bags, only: [:index]
  resources :jobs, only: [:create, :index, :show, :update] do
    resources :job_logs, only: [:create, :index, :show, :update]
  end

  resources :packages, only: [:create, :index] do
    post :deploy, on: :member
  end
  root to: 'home#index'
end
