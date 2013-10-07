Wonga::Pantry::Application.routes.draw do

  resources :bills, only: [:index]

  namespace :api do
    resources :bills, only: [:create, :show]
    resources :chef_nodes, only: [:destroy]
  end
  
  post '/api/teams/:team_id/chef_environments', :to => 'api/teams/chef_environments#create'

  get "ec2_instances/index"

  get "aws/ec2s", as: "ec2"
  get "aws/amis", as: "ami"
  get "aws/vpcs", as: "vpc"
  get "aws/security_groups", as: "secgroups"

  resources :aws_costs, only: [:index, :show]

  resources :ec2_instance_statuses, only: [:show]
  resources :jenkins_servers, except: [:destroy] do
    resources :jenkins_slaves
  end

  namespace :aws do
    resources :ec2_instances, except: [:index]
  end

  resources :teams, except: [:destroy] do
    resources :ec2_instances, controller: "teams/ec2_instances", only: [:index]
  end

  resources :ldap_users, only: [:index]

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
