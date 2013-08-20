class JenkinsServersController < ApplicationController

  def new
  	@user_teams = current_user.teams
  	@jenkins_server = JenkinsServer.new
  end

  def create
    sqs = AWS::SQS::Client.new()
    aws_utility = Wonga::AWSUtility.new(sqs)
  	@jenkins_server = aws_utility.request_jenkins_server(
      jenkins_attributes.merge({user_id: current_user.id})
    )
    if @jenkins_server.save 
      redirect_to @jenkins_server 
    else
      render :new
    end
  end

  def show
  	@jenkins_server = JenkinsServer.find(params[:id])
    @team = Team.find(@jenkins_server.team_id)
    @ec2_instance = Ec2Instance.find(@jenkins_server.ec2_instance_id)
    @user = User.find(@ec2_instance.user_id)    
  end

  private 
  
  def jenkins_attributes
  	params.require(:jenkins_server).permit(:team_id)
  end
end
