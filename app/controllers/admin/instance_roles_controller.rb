class Admin::InstanceRolesController < Admin::AdminController
  before_action :initialize_ec2_adapter
  before_action :initialize_ami, only: [:new, :create, :show]
  before_action :initialize_existing_role_and_ami, only: [:update, :edit]

  def index
    @instance_roles = InstanceRole.all
  end

  def new
    @instance_role = InstanceRole.new
  end

  def create
    @instance_role = InstanceRole.new(instance_role_attributes)

    if @instance_role.save
      redirect_to admin_instance_roles_path
    else
      render :new
    end
  end

  def update
    if @instance_role.update_attributes(instance_role_attributes)
      redirect_to admin_instance_roles_path
    else
      render :edit
    end
  end

  def destroy
    InstanceRole.destroy(params[:id])
    redirect_to admin_instance_roles_path
  end

  def show
    @instance_role = InstanceRole.find params[:id]
  end

  private

  def instance_role_attributes
    params.require(:instance_role).permit(:name, :ami_id, :chef_role, :run_list, :instance_size, :disk_size, :enabled, security_group_ids: [])
  end

  def initialize_ec2_adapter
    @ec2_adapter = Wonga::Pantry::Ec2Adapter.new(current_user)
  end

  def initialize_ami
    @ami = policy_scope(Ami).order(:name).select(:name, :id, :platform).to_a.group_by(&:platform)
  end

  def initialize_existing_role_and_ami
    @instance_role = InstanceRole.find(params[:id])
    @ami = policy_scope(Ami).order(:name).select(:name, :id, :platform).where(platform: @instance_role.ami.platform).to_a.group_by(&:platform)
  end
end
