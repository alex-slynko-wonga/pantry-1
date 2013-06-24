Pantry::Application.routes.draw do
  match '/login' => redirect("/auth/ldap")
  match '/auth/:provide/callback' => redirect("/")
  match '/auth/failure' => redirect("/login")

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
  root to: 'home#index'
end
