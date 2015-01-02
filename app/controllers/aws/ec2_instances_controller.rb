class Aws::Ec2InstancesController < ApplicationController
  before_action :initialize_environments, :initialize_instance_role, only: [:new, :create, :show]
  before_action :initialize_ec2_info, only: [:new, :show]

  def new
    @ec2_instance = if params[:id].present?
                      Ec2Instance.find(params[:id]).dup
                    else
                      Ec2Instance.new(team_id: params[:team_id])
                    end
    roles = Wonga::Pantry::AWSAdapter.new.iam_role_list
    @iam_list = roles.map(&:role_name) if roles

    authorize @ec2_instance
  end

  def create
    initialize_ec2_info(current_user)
    if ec2_instance_params[:instance_role_id].present?
      instance_role = @instance_roles.find(ec2_instance_params[:instance_role_id])
      @ec2_instance = Ec2Instance.new(ec2_instance_params.merge(instance_role.instance_attributes))
    else
      @ec2_instance = Ec2Instance.new(ec2_instance_params)

      if policy(@ec2_instance).custom_ami? && params[:custom_ami].present?
        @ec2_instance.ami = params[:custom_ami]
      elsif @ec2_instance.ami && !policy_scope(Ami).where(ami_id: @ec2_instance.ami).exists?
        @ec2_instance.ami = nil
      end

      @ec2_instance.platform = @ec2_adapter.platform_for_ami(@ec2_instance.ami)
    end

    @ec2_instance.user_id = current_user.id

    if @ec2_instance.environment
      @ec2_instance.team_id = @ec2_instance.environment.team_id
    else
      @ec2_instance.team_id = params[:team_id]
    end

    authorize @ec2_instance

    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).boot
      flash[:success] = 'Ec2 Instance request succeeded.'
      redirect_to [:aws, @ec2_instance]
    else
      flash[:error] = "Ec2 Instance request failed: #{human_errors(@ec2_instance)}"
      render action: 'new'
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]
    @history_log = policy_scope(Ec2InstanceLog).includes(:user).where(ec2_instance_id: params[:id])

    if @ec2_instance.ami && policy_scope(Ami).where(ami_id: @ec2_instance.ami).exists?
      @ami_name = Ami.where(ami_id: @ec2_instance.ami).first.name
    end

    respond_to do |format|
      format.html
      format.json { render json: @ec2_instance }
    end if stale? @ec2_instance
  end

  def destroy
    session[:return_to] ||= request.referer
    @ec2_instance = Ec2Instance.find(params[:id])
    authorize(@ec2_instance)
    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).terminate
      flash[:success] = 'Ec2 Instance deletion request success'
    else
      flash[:error] = "Ec2 Instance deletion request failed: #{human_errors(@ec2_instance)}"
    end
    redirect_to session.delete(:return_to)
  end

  def cleanup
    @ec2_instance = Ec2Instance.find(params[:id])
    authorize(@ec2_instance)
    if Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user).out_of_band_cleanup
      flash[:success] = 'Ec2 Instance cleanup request success'
    else
      flash[:error] = "Ec2 Instance cleanup request failed: #{human_errors(@ec2_instance)}"
    end
    render :show
  end

  def update
    @ec2_instance = Ec2Instance.find params[:id]
    ec2_resource = Wonga::Pantry::Ec2Resource.new(@ec2_instance, current_user)
    authorize(@ec2_instance, "#{params[:event]}?")

    if params[:event] == 'shutdown_now'
      if ec2_resource.stop
        flash[:success] = 'Shutting down has started'
      else
        flash[:error] = "An error occurred when shutting down.#{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == 'start_instance'
      if ec2_resource.start
        flash[:success] = 'Starting instance'
      else
        flash[:error] = "An error occurred while attempting to start the instance. #{human_errors(@ec2_instance)}"
      end
    elsif params[:event] == 'resize'
      if ec2_resource.resize(params[:ec2_instance][:flavor])
        flash[:success] = 'Resizing instance'
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

  def check_ec2_instance_state
    @ec2_instance = Ec2Instance.find params[:id]
    render json: @ec2_instance.human_status.to_json
  end

  private

  def ec2_instance_params
    params.require(:ec2_instance).permit(:name, :ami, :instance_role_id, :flavor, :subnet_id, :domain, :environment_id,
                                         :run_list, :iam_instance_profile, security_group_ids: [])
  end

  def initialize_ec2_info(user = pundit_user)
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(user)
    @price_list = price_list.retrieve_price_list(@ec2_adapter.flavors)
  end

  def initialize_environments
    @environments = policy_scope(Environment)
    if params[:team_id]
      @environments.where!(team_id: params[:team_id]).order(:name)
      @team = Team.find(params[:team_id])
      @team_name = @team.name
    else
      @grouped_environments = @environments.group_by_team_name
      @team_name = ''
    end
  end

  def initialize_instance_role
    @instance_roles = policy_scope(InstanceRole)
  end
end
