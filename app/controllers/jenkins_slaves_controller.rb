class JenkinsSlavesController < ApplicationController
  before_filter :load_objects
  
  def index
    @slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance)
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @ec2_instance = @jenkins_server.jenkins_slaves.find(params[:id]).ec2_instance
  end
  
private
  def load_objects
   @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
  end
end
