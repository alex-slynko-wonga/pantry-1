class TeamsController < ApplicationController
  def create
    Team.create(params.permit(:name,:description))
  end

  def index
  	@teams = Team.all
  end

  def show
      @team = Team.find(params[:id])
  end

  def update
  end
end
