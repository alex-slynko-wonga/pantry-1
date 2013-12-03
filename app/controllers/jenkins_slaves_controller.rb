class JenkinsSlavesController < ApplicationController
  before_filter :load_objects

  def index
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance)

    respond_to do |format|
      format.html
    end
  end

  def show
    @jenkins_slave = @jenkins_server.jenkins_slaves.find(params[:id])
    @ec2_instance = @jenkins_slave.ec2_instance
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
      team: @jenkins_server.team
    }

    if aws_utility.request_jenkins_instance(attributes, @jenkins_slave)
      flash[:notice] = "Jenkins slave request succeeded."
      Wonga::Pantry::Ec2InstanceState.new(
        @jenkins_slave.ec2_instance, 
        current_user, 
        { 'event' => "ec2_boot" }
      ).change_state      
      redirect_to jenkins_server_jenkins_slaves_url(@jenkins_server)      
    else
      flash[:error] = "Error: #{@jenkins_slave.errors.full_messages.to_sentence}"
      @user_teams = current_user.teams
      render :new
    end
  end

  def destroy
    @jenkins_slave = @jenkins_server.jenkins_slaves.find(params[:id])
    server_fqdn = "#{@jenkins_server.ec2_instance.name}.#{@jenkins_server.ec2_instance.domain}"
    
    if Wonga::Pantry::JenkinsSlaveDestroyer.new(@jenkins_slave, server_fqdn, 80, current_user).delete
      flash[:error] = "Jenkins slave deletion request failed: #{@jenkins_slave.errors.full_messages.to_sentence}"
    else
      flash[:notice] = "Jenkins slave deletion request succeeded"
    end
    
    redirect_to jenkins_server_jenkins_slaves_url(@jenkins_server)
  end

  private
  def load_objects
    @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
    redirect_to @jenkins_server and return unless @jenkins_server.ec2_instance.bootstrapped?
  end
end
