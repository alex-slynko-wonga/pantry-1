Pantry::Application.routes.draw do
  resources :data_bags, only: [:index]
  resources :job_logs, only: [:create, :index]
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  resources :packages, only: [:create, :index]
  root to: 'home#index'
end
