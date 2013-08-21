class JenkinsSlavesController < ApplicationController
  before_filter :load_objects
  
  def index
    @slaves = @jenkins_server.jenkins_slaves
    @ec2_instances = JenkinsSlave.ec2_instances(@slaves)
    
    respond_to do |format|
      format.html
      format.json { render json: @ec2_instances }
    end
  end
  
  def show
    @ec2_instance = JenkinsSlave.find(params[:id]).ec2_instance
  end
  
private
 def load_objects
   @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
 end
end
