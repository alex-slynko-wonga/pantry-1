class Aws::Ec2InstancesController < ApplicationController
  before_filter :initialize_ec2_adapter, only: [:new, :create]

  def new
    @ec2_instance = Ec2Instance.new
  end

  def create
    platform = @ec2_adapter.platform_for_ami(ec2_instance_params[:ami])
    @ec2_instance = Ec2Instance.new(
      ec2_instance_params.merge(
        {user_id: current_user.id, platform: platform}
      )
    )
    
    if @ec2_instance.save
      message = Wonga::Pantry::BootMessage.new(@ec2_instance).boot_message
      Wonga::Pantry::SQSSender.new.send_message(message)
      redirect_to "/aws/ec2_instances/#{@ec2_instance.id}"
    else
      render :action => "new"
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]
    respond_to do |format|
      format.html
      format.json { render json: @ec2_instance }
    end
  end

  def update
    @ec2_instance = Ec2Instance.find params[:id]
    if params[:booted]
      @ec2_instance.complete! :booted
    end
    if params[:instance_id]
      @ec2_instance.exists! params[:instance_id]
    end
    if params[:bootstrapped]
      @ec2_instance.complete! :bootstrapped
    end
    if params[:joined]
      @ec2_instance.complete! :joined
    end

    respond_to do |format|
      format.html
      format.json { render json: @ec2_instance }
    end
  end

  private

  def ec2_instance_params
    params.require(:ec2_instance).permit(:name, :team_id, :user_id, :ami, :flavor, :subnet_id, :domain, :chef_environment, :run_list, :platform, :security_group_ids => [])
  end

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new
  end
end

