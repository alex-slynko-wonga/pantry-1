class JenkinsSlavesController < ApplicationController
  def index
    @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
    @slaves = @jenkins_server.jenkins_slaves.includes(:ec2_instance)
    
    respond_to do |format|
      format.html
    end
  end
  
  def show
    
  end
end
