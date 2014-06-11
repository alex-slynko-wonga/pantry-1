class Aws::Ec2InstancesController < ApplicationController
  before_action :initialize_ec2_adapter, only: [:new, :create]

  def new
    @ec2_instance = Ec2Instance.new
    @ec2_instance.team_id = params[:team_id] unless params[:team_id].blank?
    @ec2_instance.team ||= current_user.teams.first
    authorize @ec2_instance
  end

  def create
    @ec2_instance = Ec2Instance.new(ec2_instance_params.merge({user_id: current_user.id}))
    if policy(@ec2_instance).custom_ami? && params[:custom_ami].present?
      @ec2_instance.ami = params[:custom_ami]
    elsif @ec2_instance.ami && !policy_scope(Ami).where(ami_id: @ec2_instance.ami).exists?
      @ec2_instance.ami = nil
    end

    @ec2_instance.platform = @ec2_adapter.platform_for_ami(@ec2_instance.ami)

    ec2_resource = Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user)
    @ec2_instance.team ||= current_user.teams.first
    authorize @ec2_instance

    if ec2_resource.boot
      flash[:notice] = "Ec2 Instance request succeeded."
      redirect_to [:aws, @ec2_instance]
    else
      flash[:error] = "Ec2 Instance request failed: #{human_errors(@ec2_instance)}"
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

  def destroy
    @ec2_instance = Ec2Instance.find(params[:id])
    authorize(@ec2_instance)
    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).terminate
      flash[:notice] = "Ec2 Instance deletion request success"
    else
      flash[:error] = "Ec2 Instance deletion request failed: #{human_errors(@ec2_instance)}"
    end
    render :show
  end

  def update
    @ec2_instance = Ec2Instance.find params[:id]
    ec2_resource = Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user)
    authorize(@ec2_instance, "#{params[:event]}?")

    if params[:event] == "shutdown_now"
      if ec2_resource.stop
        flash[:notice] = "Shutting down has started"
      else
        flash[:error] = "An error occurred when shutting down.#{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == "start_instance"
      if ec2_resource.start
        flash[:notice] = "Starting instance"
      else
        flash[:error] = "An error occurred while attempting to start the instance. #{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == "resize"
      if ec2_resource.resize(params[:ec2_instance][:flavor])
        flash[:notice] = "Resizing instance"
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
    params.require(:ec2_instance).permit(:name, :team_id, :user_id, :ami, :flavor, :subnet_id, :domain, :environment_id, :run_list, :platform, :security_group_ids => [])
  end

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(current_user)
  end
end
