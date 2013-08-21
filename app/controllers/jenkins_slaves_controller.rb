class JenkinsSlavesController < ApplicationController
  def index
    @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
    @slaves = @jenkins_server.jenkins_slaves
    @ec2_instances = JenkinsSlave.ec2_instances(@slaves)
    
    respond_to do |format|
      format.html
      format.json { render json: @ec2_instances }
    end
  end
  
  def show
    
  end
end
