class Api::Ec2InstancesController < ApiController
  def update
    Wonga::Pantry::Ec2InstanceState.new(Ec2Instance.find(params[:id]), nil, params).change_state
    respond_with {}
  end
end
