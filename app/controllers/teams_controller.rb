class TeamsController < ApplicationController
  def team_params
    params.require(:team).permit(:name, :description)
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to :index
      else
        render :new
    end
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
