class JenkinsServersController < ApplicationController
  def new
	@user_teams = current_user.teams
	@jenkins_server = JenkinsServer.new
  end

  def create
	@jenkins_server = JenkinsServer.new()
	@jenkins_server.Team = get_teams
	
	if @jenkins_server.save
		redirect_to @jenkins_server
	else
		render :new
	end
  end

  def show
  end

  private 
  
  def get_teams
	return nil if params[:jenkins_server].blank? 
	Team.find(params[:jenkins_server][:team_id])
  end

end
