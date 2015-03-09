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
    respond_with({ msg: 'success' }, location: aws_ec2_instance_url)
  end

  def start
    ec2_instance = Ec2Instance.find(params[:id])
    Wonga::Pantry::Ec2Resource.new(ec2_instance).start_automatically
    respond_with({ msg: 'success' }, location: aws_ec2_instance_url)
  end

  def shut_down
    ec2_instance = Ec2Instance.find(params[:id])
    Wonga::Pantry::Ec2Resource.new(ec2_instance).stop_automatically
    respond_with({ msg: 'success' }, location: aws_ec2_instance_url)
  end

  def ready_for_shutdown
    render json: ScheduledEvent.ready_for_shutdown.pluck(:ec2_instance_id)
  end

  def ready_for_start
    render json: ScheduledEvent.ready_for_start.pluck(:ec2_instance_id)
  end
end
