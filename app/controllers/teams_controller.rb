class TeamsController < ApplicationController
  before_filter :get_team, :only => [:show, :edit, :update]
  before_filter :check_permission, :only => [:edit, :update]

  def new
    @team = Team.new
    @team.users << current_user
  end

  def create
    @team = Team.new(team_params)
    @team.users = users
    if @team.save
      chef_utility = Wonga::Pantry::ChefUtility.new
      chef_utility.request_chef_environment(@team)
      flash[:notice] = "Team created successfully"
      redirect_to @team
    else
      flash[:error] = "Team creation failed: #{@team.errors.full_messages.to_sentence}"      
      render :new
    end
  end

  def index
    @teams = Team.all
  end

  def show
    @jenkins_server = @team.jenkins_server
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance) if @jenkins_server
    @ec2_instances = @team.ec2_instances
    @can_create_ec2_instance = current_user.member_of_team?(@team)
  end

  def edit
  end

  def update
    @team.users = users
    if @team.update_attributes(team_params)
      redirect_to @team
      flash[:notice] = "Team updated successfully"      
    else
      flash[:error] = "Team update failed: #{@team.errors.full_messages.to_sentence}"            
      render :edit
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
    params.require(:team).permit(:name, :description)
  end
  
  def check_permission
    flash[:error] = 'Permission denied: you cannot change this team.' and redirect_to root_url unless current_user.member_of_team?(@team)
  end
end
