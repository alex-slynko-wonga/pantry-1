class JenkinsServersController < ApplicationController
  def new
	@user_teams = current_user.teams
	@jenkins_server = JenkinsServer.new
  end

  def create
	@jenkins_server = JenkinsServer.new(jenkins_attributes)

	if @jenkins_server.save
		redirect_to @jenkins_server
	else
		render :new
	end
  end

  def show
  end

  private 
  
  def jenkins_attributes
	params.require(:jenkins_server).permit(:team_id)
  end
end
