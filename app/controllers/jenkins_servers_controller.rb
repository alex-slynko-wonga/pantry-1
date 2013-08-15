class JenkinsServersController < ApplicationController
  def new
	@user_teams = User.find(current_user.id).teams
	@jenkins_server = JenkinsServer.new
  end

  def create
  end

  def show
  end
end
