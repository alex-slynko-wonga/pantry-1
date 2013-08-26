class JenkinsServersController < ApplicationController

  def new
  	@user_teams = current_user.teams
  	@jenkins_server = JenkinsServer.new
  end

  def create
    aws_utility = Wonga::Pantry::AWSUtility.new
    @jenkins_server = JenkinsServer.new(team_id: attributes[:team_id])
    attributes = jenkins_attributes.merge(
      { user_id: current_user.id }
    )
    if aws_utility.request_jenkins_instance(attributes, @jenkins_server)
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
