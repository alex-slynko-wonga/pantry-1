class Aws::Ec2InstancesController < ApplicationController
  before_action :initialize_ec2_adapter, :initialize_environments, :initialize_instance_role, only: [:new, :create]

  def new
    @ec2_instance = Ec2Instance.new
    @ec2_instance.team_id = params[:team_id] unless params[:team_id].blank?
    authorize @ec2_instance
  end

  def create
    if ec2_instance_params[:instance_role_id].present?
      @instance_role = @instance_roles.find(ec2_instance_params[:instance_role_id])
      @ec2_instance = Ec2Instance.new(ec2_instance_params.merge(user_id: current_user.id,
                                                                flavor: @instance_role.instance_size,
                                                                ami: @instance_role.ami.ami_id,
                                                                run_list: @instance_role.full_run_list,
                                                                security_group_ids: @instance_role.security_group_ids,
                                                                volume_size: @instance_role.disk_size))
    else
      @ec2_instance = Ec2Instance.new(ec2_instance_params.merge(user_id: current_user.id))
    end

    if policy(@ec2_instance).custom_ami? && params[:custom_ami].present?
      @ec2_instance.ami = params[:custom_ami]
    elsif @ec2_instance.ami && !policy_scope(Ami).where(ami_id: @ec2_instance.ami).exists?
      @ec2_instance.ami = nil
    end

    if @ec2_instance.environment
      @ec2_instance.team_id = @ec2_instance.environment.team_id
    else
      @ec2_instance.team_id = params[:team_id]
    end

    @ec2_instance.platform = @ec2_adapter.platform_for_ami(@ec2_instance.ami)

    authorize @ec2_instance

    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).boot
      flash[:notice] = 'Ec2 Instance request succeeded.'
      redirect_to [:aws, @ec2_instance]
    else
      flash[:error] = "Ec2 Instance request failed: #{human_errors(@ec2_instance)}"
      render action: 'new'
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]

    if @ec2_instance.ami && policy_scope(Ami).where(ami_id: @ec2_instance.ami).exists?
      @ami_name = Ami.where(ami_id: @ec2_instance.ami).first.name
    end

    respond_to do |format|
      format.html
      format.json { render json: @ec2_instance }
    end
  end

  def destroy
    @ec2_instance = Ec2Instance.find(params[:id])
    authorize(@ec2_instance)
    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).terminate
      flash[:notice] = 'Ec2 Instance deletion request success'
    else
      flash[:error] = "Ec2 Instance deletion request failed: #{human_errors(@ec2_instance)}"
    end
    render :show
  end

  def update
    @ec2_instance = Ec2Instance.find params[:id]
    ec2_resource = Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user)
    authorize(@ec2_instance, "#{params[:event]}?")

    if params[:event] == 'shutdown_now'
      if ec2_resource.stop
        flash[:notice] = 'Shutting down has started'
      else
        flash[:error] = "An error occurred when shutting down.#{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == 'start_instance'
      if ec2_resource.start
        flash[:notice] = 'Starting instance'
      else
        flash[:error] = "An error occurred while attempting to start the instance. #{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == 'resize'
      if ec2_resource.resize(params[:ec2_instance][:flavor])
        flash[:notice] = 'Resizing instance'
      else
        flash[:error] = "An error occurred while attempting to resize the instance. #{human_errors(@ec2_instance)}"
      end
    end

    respond_to do |format|
      format.json { render json: @ec2_instance }
      format.html do
        redirect_to request.referer
      end
    end
  end

  private

  def ec2_instance_params
    params.require(:ec2_instance).permit(:name, :user_id, :ami, :instance_role_id, :flavor, :subnet_id, :domain, :environment_id, :run_list, :platform, security_group_ids: [])
  end

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(current_user)
  end

  def initialize_environments
    @environments = policy_scope(Environment)
    if params[:team_id]
      @environments.where!(team_id: params[:team_id]).order(:name)
      @team_name = Team.find(params[:team_id]).name
    else
      @grouped_environments = @environments.group_by_team_name
    end
  end

  def initialize_instance_role
    @instance_roles = policy_scope(InstanceRole)
  end
end
