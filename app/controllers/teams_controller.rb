class TeamsController < ApplicationController
  def create
  end

  def index
  end

  def show
      @team = Team.find(params[:id])
      @members = TeamMember.find(@team.users)
  end

  def update
  end
end
