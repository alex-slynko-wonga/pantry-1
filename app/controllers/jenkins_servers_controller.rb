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
    return unless load_servers
    @jenkins_server = JenkinsServer.new(team: @user_teams.first)
    authorize @jenkins_server
  end

  def create
    aws_utility = Wonga::Pantry::JenkinsUtility.new
    @jenkins_server = JenkinsServer.new(jenkins_attributes)
    authorize(@jenkins_server)

    attributes = jenkins_attributes.merge(
      user_id: current_user.id
    )
    if aws_utility.request_jenkins_instance(attributes, @jenkins_server)
      flash[:success] = 'Jenkins server request succeeded.'
      redirect_to @jenkins_server
    else
      flash[:error] = "Jenkins server request failed: #{human_errors(@jenkins_server)}"
      render :new if load_servers
    end
  end

  def show
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(current_user)
    @jenkins_server = JenkinsServer.find(params[:id])
    @team = @jenkins_server.team
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.not_terminated)
    @ec2_instance = @jenkins_server.ec2_instance
  end

  private

  def jenkins_attributes
    params.require(:jenkins_server).permit(:team_id, :instance_role_id)
  end

  def load_servers
    @user_teams = current_user.teams.with_environment.without_jenkins
    if @user_teams.empty?
      flash[:error] = 'You cannot create a server because you do not belong to this team'
      redirect_to jenkins_servers_path
      return false
    end
    true
  end
end
