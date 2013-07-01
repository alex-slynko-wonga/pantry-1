class TeamsController < ApplicationController
  before_filter :get_team, :only => [:show, :edit, :update]

  def get_team
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to @team
    else
      render :new
    end
  end

  def index
    @teams = Team.all
  end

  def show
  end

  def edit
  end

  def update
    if @team.update_attributes(team_params)
      redirect_to @team
    else
      render :edit
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
