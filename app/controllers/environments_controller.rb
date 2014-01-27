class EnvironmentsController < ApplicationController
  before_filter :get_team

  def new
    @environment = Environment.new(team_id: @team.id)
  end

  def create
    @environment = @team.environments.build(environment_parameters)
    authorize(@environment)
    @environment.save ? redirect_to(@team) : render('new')
  end

  private

  def environment_parameters
    params.require("environment").permit(:name, :description, :chef_environment, :environment_type)
  end

  def get_team
    @team = Team.find(params[:team_id])
  end
end
