class Api::ChefNodesController < ApiController
  def destroy
    user = User.where(id: params[:user_id]).first || nil
    ec2_instance = Ec2Instance.find(params[:id])
    Wonga::Pantry::Ec2InstanceState.new(ec2_instance, user, {'event' => :terminated, 'bootstrapped' => false}).change_state
    respond_with {}
  end
end
