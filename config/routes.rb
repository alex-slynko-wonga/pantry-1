Pantry::Application.routes.draw do
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  resources :packages, only: :create

  root to: 'home#index'
end
