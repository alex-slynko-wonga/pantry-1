class EnvironmentsController < ApplicationController
  before_filter :get_team, only: [:new, :create]
  before_filter :get_environment, only: [:show, :edit, :update]

  def new
    @environment = @team.environments.build(environment_type: params[:environment_type])
  end

  def create
    @environment = @team.environments.build(environment_parameters)
    authorize(@environment)
    if @environment.save
      chef_utility = Wonga::Pantry::ChefUtility.new
      chef_utility.request_chef_environment(@team, @environment)
      flash[:notice] = "Environment created"
      redirect_to(@team)
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
      flash[:notice] = "Environment updated successfully"
    else
      flash[:error] = "Environment update failed: #{human_errors(@environment)}"
      render :edit
    end
  end

  private

  def environment_parameters
    params.require("environment").permit(:name, :description, :environment_type)
  end

  def environment_update_parameters
    params.require("environment").permit(:name, :description)
  end

  def get_team
    @team = Team.find(params[:team_id])
  end

  def get_environment
    @environment = Environment.find(params[:id])
  end
end
