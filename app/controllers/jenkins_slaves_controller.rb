class JenkinsSlavesController < ApplicationController
  def index
    @jenkins_server = JenkinsServer.find(params[:jenkins_server_id])
    @slaves = @jenkins_server.jenkins_slaves
  end
end
