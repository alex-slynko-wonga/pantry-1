class TeamsController < ApplicationController
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
    @team = Team.find(params[:id])
  end

  def edit
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])
    @team.update_attributes(:name => params[:team][:name],
                            :description => params[:team][:description])
    redirect_to :action => 'show', :id => @team
  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
