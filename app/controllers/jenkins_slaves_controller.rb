class JenkinsSlavesController < ApplicationController
  before_filter :load_objects
  
  def index
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance)
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @ec2_instance = @jenkins_server.jenkins_slaves.find(params[:id]).ec2_instance
    @team = @jenkins_server.team
  end
  
  def new
    @jenkins_slave = JenkinsSlave.new
    @user_teams = current_user.teams
  end
  
  def create
    aws_utility = Wonga::Pantry::AWSUtility.new
    @jenkins_slave = JenkinsSlave.new(jenkins_server: @jenkins_server)
    attributes = { 
      user_id: current_user.id, 
      name: "#{@jenkins_server.team.name.parameterize}-slave#{@jenkins_server.jenkins_slaves.count + 1}",
      team: @jenkins_server.team
    }
    aws_utility.request_jenkins_instance(attributes, @jenkins_slave)
    
    if @jenkins_slave.persisted?
      redirect_to jenkins_server_jenkins_slave_path(@jenkins_server, @jenkins_slave)
    else
      @user_teams = current_user.teams
      render :new
    end
  end
  
  def new
    @jenkins_slave = JenkinsSlave.new
    @user_teams = current_user.teams
  end
  
  def create
    aws_utility = Wonga::Pantry::AWSUtility.new
    @jenkins_slave = JenkinsSlave.new(jenkins_server: @jenkins_server)
    attributes = { 
      user_id: current_user.id, 
      name: @jenkins_server.team.name,
      team: @jenkins_server.team
    }
    aws_utility.request_jenkins_instance(attributes, @jenkins_slave)
    
    if @jenkins_slave.persisted?
      redirect_to jenkins_server_jenkins_slave_path(@jenkins_server, @jenkins_slave)
    else
      @user_teams = current_user.teams
      render :new
    end
  end
  
private
  def load_objects
   @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
  end
end
