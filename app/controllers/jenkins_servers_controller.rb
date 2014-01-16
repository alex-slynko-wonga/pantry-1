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
      flash[:notice] = "Jenkins server request succeeded."
      Wonga::Pantry::Ec2InstanceState.new(
        @jenkins_server.ec2_instance,
        current_user,
        { "event" => "ec2_boot" }
      ).change_state
      redirect_to @jenkins_server
    else
      flash[:error] = "Jenkins server request failed: #{human_errors(@jenkins_server)}"
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
    if @user_teams.empty?
      flash[:error] = "You cannot create a server because you do not belong to this team"
      redirect_to jenkins_servers_path and return
    end
  end
end
