Wonga::Pantry::Application.routes.draw do
  namespace :admin do
    resources :maintenance_windows
    resources :amis, except: [:show]
    resources :instance_roles
  end

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  get 'ec2_instance_costs/index'

  namespace :api do
    resources :chef_nodes, only: [:destroy]
    resources :ec2_instances, only: [:update] do
      post :update_from_aws, on: :collection
      member do
        post :update_info_from_aws
      end
    end
    resources :jenkins_slaves, only: [:update]
    resources :costs, only: [:create]
    resources :teams, only: [] do
      resources :chef_environments, controller: 'teams/chef_environments', only: [:update]
    end
  end

  resources :ec2_instances, only: [:show] do
    get 'aws_status', on: :member
  end

  resources :queues, only: [:index, :show]
  resources :aws_costs, only: [:index, :show]
  resources :total_costs, only: [:show]
  resources :ec2_instances, except: [:index]
  resources :ec2_instance_costs, only: [:index, :show]

  resources :jenkins_servers, except: [:destroy] do
    resources :jenkins_slaves
  end

  namespace :aws do
    resources :ec2_instances, except: [:index] do
      member do
        delete :cleanup
      end
    end
    resources :ec2_amis, only: [:show]
  end

  resources :teams, except: [:destroy] do
    resources :ec2_instances, controller: 'teams/ec2_instances', only: [:index]
    resources :environments
    post :deactivate, on: :member
  end

  resources :ldap_users, only: [:index]

  get '/login', to: 'sessions#new', as: :login
  post '/auth/ldap/callback', to: 'sessions#create'
  get '/auth/ldap/callback', to: 'sessions#create'
  get '/auth/failure', to: 'sessions#failure'
  get '/logout', to: 'sessions#destroy'

  resources :users, except: [:create, :destroy]
  root to: 'home#index'

  resources :environments, only: [:show, :edit, :update] do
    member do
      put :hide
    end
  end

end
