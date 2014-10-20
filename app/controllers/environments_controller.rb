class EnvironmentsController < ApplicationController
  before_filter :get_team, only: [:new, :create]

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
    @environment = Environment.find params[:id]
    @ec2_instances = @environment.ec2_instances
  end

  private

  def environment_parameters
    params.require("environment").permit(:name, :description, :chef_environment, :environment_type)
  end

  def get_team
    @team = Team.find(params[:team_id])
  end
end
