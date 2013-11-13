class Api::ChefNodesController < ApiController
  def destroy
    ec2_instance = Ec2Instance.find(params[:id])
    Wonga::Pantry::Ec2InstanceState.new(ec2_instance, nil, params).change_state
    respond_with {}
  end
end
