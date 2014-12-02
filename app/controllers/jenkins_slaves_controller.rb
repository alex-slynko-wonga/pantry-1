class JenkinsSlavesController < ApplicationController
  before_action :load_objects

  def index
    @jenkins_slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.not_terminated)

    respond_to do |format|
      format.html
    end
  end

  def show
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(pundit_user)
    @jenkins_slave = @jenkins_server.jenkins_slaves.find(params[:id])
    @ec2_instance = @jenkins_slave.ec2_instance
    @team = @jenkins_server.team
  end

  def new
    @jenkins_slave = @jenkins_server.jenkins_slaves.build
    authorize(@jenkins_slave)
  end

  def create
    aws_utility = Wonga::Pantry::JenkinsUtility.new
    @jenkins_slave = @jenkins_server.jenkins_slaves.build
    attributes = {
      user_id: current_user.id,
      team: @jenkins_server.team,
      instance_role_id: params[:jenkins_slave][:instance_role_id]
    }
    authorize(@jenkins_slave)

    if aws_utility.request_jenkins_instance(attributes, @jenkins_slave)
      flash[:success] = 'Jenkins slave request succeeded.'
      redirect_to jenkins_server_jenkins_slaves_url(@jenkins_server)
    else
      flash[:error] = "Error: #{human_errors(@jenkins_slave)}"
      render :new
    end
  end

  def destroy
    @jenkins_slave = @jenkins_server.jenkins_slaves.find(params[:id])

    if Wonga::Pantry::Ec2Resource.new(@jenkins_slave.ec2_instance, current_user).terminate
      flash[:success] = 'Jenkins slave deletion request succeeded'
    else
      flash[:error] = "Jenkins slave deletion request failed: #{human_errors(@jenkins_slave) + human_errors(@jenkins_slave.ec2_instance)}"
    end

    redirect_to jenkins_server_jenkins_slaves_url(@jenkins_server)
  end

  private

  def load_objects
    @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
  end
end
