class Api::JenkinsSlavesController < ApiController
  def update
    jenkins_slave = JenkinsSlave.find(params[:id])
    jenkins_slave.update_attributes(jenkins_attributes)
    respond_with jenkins_slave
  end

  private

  def jenkins_attributes
    params.require(:jenkins_slave).permit(:removed)
  end
end
