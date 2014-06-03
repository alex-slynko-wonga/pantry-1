class Api::Ec2InstancesController < ApiController
  def update
    user = User.where(id: params[:user_id]).first || nil
    Wonga::Pantry::Ec2InstanceState.new(Ec2Instance.find(params[:id]), user, params).change_state!
    respond_with {}
  end
end
