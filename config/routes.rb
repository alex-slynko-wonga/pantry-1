Pantry::Application.routes.draw do
  resources :data_bags, only: [:index]

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  resources :packages, only: [:create, :index]
  root to: 'home#index'
end
