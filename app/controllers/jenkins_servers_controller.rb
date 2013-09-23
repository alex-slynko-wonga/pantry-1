class JenkinsServersController < ApplicationController

  def index
    @user_teams = current_user.teams
    @current_team = @user_teams.find(params[:team_id]) if params[:team_id]
    @current_team = @user_teams.first if @user_teams && @user_teams.count == 1
    @jenkins_servers = JenkinsServer.includes(:ec2_instance)

    if @current_team
      @jenkins_servers = @jenkins_servers.where(team_id: @current_team.id)
    else
      @jenkins_servers = @jenkins_servers.where(team_id: @user_teams.map(&:id))
    end
  end

  def new
    @jenkins_server = JenkinsServer.new
    load_servers
  end

  def create
    aws_utility = Wonga::Pantry::AWSUtility.new
    @jenkins_server = JenkinsServer.new(jenkins_attributes)
    attributes = jenkins_attributes.merge(
      { user_id: current_user.id }
    )
    if aws_utility.request_jenkins_instance(attributes, @jenkins_server)
      redirect_to @jenkins_server
    else
      load_servers
      render :new
    end
  end

  def show
    @jenkins_server = JenkinsServer.find(params[:id])
    @team = @jenkins_server.team
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance)
    @ec2_instance = @jenkins_server.ec2_instance
  end

  private 

  def jenkins_attributes
    params.require(:jenkins_server).permit(:team_id)
  end

  def load_servers
    @user_teams = current_user.teams.with_environment.without_jenkins
    redirect_to jenkins_servers_path and return if @user_teams.empty?
  end
end
