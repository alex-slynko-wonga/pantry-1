class TeamsController < ApplicationController
  def create
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
