class Api::Ec2InstancesController < ApiController
  def update
    Wonga::Pantry::Ec2InstanceState.new(Ec2Instance.find(params[:id]), Ec2Instance.find(params[:id]).user, params).change_state
    respond_with {}
  end
end
