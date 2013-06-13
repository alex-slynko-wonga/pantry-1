Pantry::Application.routes.draw do
  resources :data_bags, only: [:index]
  resources :jobs, only: [:create, :index, :show, :update] do
    resources :job_log, only: [:create, :index, :show, :update]
  end
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  resources :packages, only: [:create, :index]
  root to: 'home#index'
end
