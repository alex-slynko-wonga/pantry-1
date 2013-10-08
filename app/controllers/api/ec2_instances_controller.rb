class Api::Ec2InstancesController < ApiController
  def update
    ec2_instance = Ec2Instance.find params[:id]
    ec2_instance.complete! params
    respond_with [:api, ec2_instance]    
  end
end
