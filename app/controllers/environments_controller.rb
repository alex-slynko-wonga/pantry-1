class EnvironmentsController < ApplicationController
  before_action :load_team, only: [:new, :create, :index]
  before_action :load_environment, only: [:show, :edit, :update, :hide]

  def index
    @environments = @team.environments
  end

  def new
    @environment = @team.environments.build(environment_type: params[:environment_type])
    session[:return_to] ||= request.referer
  end

  def create
    @environment = @team.environments.build(environment_parameters)
    authorize(@environment)
    if @environment.save
      chef_utility = Wonga::Pantry::ChefUtility.new
      chef_utility.request_chef_environment(@team, @environment)
      flash[:notice] = 'Environment created'
      redirect_to session.delete(:return_to) || @team
    else
      flash[:error] = "Environment creation failed: #{human_errors(@environment)}"
      render('new')
    end
  end

  def show
    @ec2_instances = @environment.ec2_instances
  end

  def edit
    authorize(@environment)
  end

  def update
    authorize(@environment)
    if @environment.update_attributes(environment_update_parameters)
      redirect_to @environment
      flash[:notice] = 'Environment updated successfully'
    else
      flash[:error] = "Environment update failed: #{human_errors(@environment)}"
      render :edit
    end
  end

  def hide
    authorize(@environment)

    if @environment.hide
      flash[:notice] = 'Environment was hidden successfully'
    else
      flash[:error] = "Environment was not hidden with errors: #{human_errors(@environment)}"
    end

    redirect_to @environment
  end

  private

  def environment_parameters
    params.require('environment').permit(:name, :description, :environment_type)
  end

  def environment_update_parameters
    params.require('environment').permit(:name, :description)
  end

  def load_team
    @team = Team.find(params[:team_id])
  end

  def load_environment
    @environment = Environment.find(params[:id])
  end
end
