class Api::JenkinsSlavesController < ApiController
  def update
    jennkins_slave = JenkinsSlave.find(params[:id])
    jennkins_slave.update_attributes(jenkins_attributes)
    respond_with {}
  end
  
private
  
  def jenkins_attributes
    params.require(:jenkins_slave).permit(:removed)
  end
end
