class Api::Ec2InstancesController < ApiController
  def update
    user = User.where(id: params[:user_id]).first || nil
    Wonga::Pantry::Ec2InstanceState.new(Ec2Instance.find(params[:id]), user, params).change_state!
    respond_with {}
  end

  def update_instances_from_aws
    results = Wonga::Pantry::Ec2InstancesUpdater.new.update_from_aws
    render json: results
  end

  def update_info_from_aws
    ec2_instance = Ec2Instance.find(params[:id])
    ec2_instance.update_info
    render json: {}
  end
end
