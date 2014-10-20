class TeamsController < ApplicationController
  before_action :get_team, :only => [:show, :edit, :update, :deactivate]

  def new
    @team = Team.new
    @team.users << current_user
  end

  def create
    @team = Team.new(team_params)
    @team.users = users
    if @team.save
      flash[:notice] = "Team created successfully"
      redirect_to @team
    else
      flash[:error] = "Team creation failed: #{human_errors(@team)}"
      render :new
    end
  end

  def index
    @teams = Team.all
    @teams = @teams.inactive if params[:inactive] && policy(Team).see_inactive_teams?
  end

  def show
    @jenkins_server = @team.jenkins_server
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.not_terminated) if @jenkins_server
    @environments = @team.environments
  end

  def edit
    authorize(@team)
  end

  def update
    authorize(@team)
    @team.users = users
    if @team.update_attributes(team_params)
      redirect_to @team
      flash[:notice] = "Team updated successfully"
    else
      flash[:error] = "Team update failed: #{human_errors(@team)}"
      render :edit
    end
  end

  def deactivate
    authorize(@team)
    if params[:confirm] == @team.name
      @team.update_attributes(disabled: true)
      flash[:notice] = "Team #{@team.name} deactivated"
      redirect_to teams_url
    else
      flash[:error] = "Confirmation is not provided"
      redirect_to @team
    end
  end

  private

  def get_team
    @team = Team.find(params[:id])
  end

  def users
    return [current_user] if params[:users].blank? # make sure there is at least on user in the list
    @users ||= params[:users].each_slice(2).with_object([]) do |(username, name), user_array|
      user = User.where(username: username).first
      if user.nil?
        user = User.new(name: name, username: username)
        user.save
      end
      user_array << user
    end
  end

  def team_params
    params.require(:team).permit(:name, :product, :region, :description)
  end
end
