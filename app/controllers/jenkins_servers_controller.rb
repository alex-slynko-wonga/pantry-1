class JenkinsServersController < ApplicationController
  
  def index
    @user_teams = current_user.teams
    @current_team = Team.find(params[:team_id]) if params[:team_id]
    @jenkins_servers = JenkinsServer.includes(:ec2_instance) if @user_teams.size == 1
    @jenkins_servers = JenkinsServer.where(team_id: params[:team_id]).includes(:ec2_instance) if params[:team_id]
  end

  def new
  	@user_teams = current_user.teams
  	@jenkins_server = JenkinsServer.new
  end

  def create
    aws_utility = Wonga::Pantry::AWSUtility.new
    name = Team.find(jenkins_attributes[:team_id]).name
    attributes = jenkins_attributes.merge(
      {user_id: current_user.id, name: name}
    )
    @jenkins_server = JenkinsServer.new(team_id: attributes[:team_id])
    aws_utility.request_jenkins_instance(attributes, @jenkins_server)
    if @jenkins_server.persisted?
      redirect_to @jenkins_server
    else
      @user_teams = current_user.teams
      render :new
    end
  end

  def show
  	@jenkins_server = JenkinsServer.find(params[:id])
    @team = @jenkins_server.team
    @ec2_instance = @jenkins_server.ec2_instance
  end

  private 
  
  def jenkins_attributes
  	params.require(:jenkins_server).permit(:team_id)
  end
end
