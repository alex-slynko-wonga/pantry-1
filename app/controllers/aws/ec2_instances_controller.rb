class Aws::Ec2InstancesController < ApplicationController
  before_filter :initialize_ec2_instance

  def initialize_ec2_instance(ec2 = AWS::EC2::Client.new)
    @ec2_instance = Ec2Instance.new
    amis = ec2.describe_images({owners: ['self']})[:images_set]
    @ami_platforms = {}
    @ami_options = amis.each_with_object({}) do |ami, ami_options|
      platform = (ami[:platform] == "windows") ? "windows" : "linux"
      ami_options["#{ami[:name]} - #{platform}"] = ami[:image_id]
      @ami_platforms[ami[:image_id]] = platform    
    end
    subnets = ec2.describe_subnets()[:subnet_set]
    @subnet_options = subnets.each_with_object({}) do |subnet, subnet_options|
      subnet_options[subnet[:subnet_id]] = subnet[:subnet_id]
    end
    secgroups = ec2.describe_security_groups(
        :filters => [ { :name =>"vpc-id",
                        :values =>["vpc-00110011"] } ]
      )[:security_group_info]
    @secgroup_options = secgroups.each_with_object({}) do |secgroup, secgroup_options|
      secgroup_options[secgroup[:group_name]] = secgroup[:group_id]
    end
    flavors = [
      {id: "t1.micro"},
      {id: "m1.small"},
      {id: "m1.medium"},
      {id: "m1.large"}
    ]
    @flavor_options = flavors.each_with_object({}) do |flavor, flavor_options|
      flavor_options[flavor[:id]] = flavor[:id]
    end
  end

  def create
    platform = @ami_platforms[ec2_instance_params["ami"]]    
    @ec2_instance = Ec2Instance.new(
      ec2_instance_params.merge(
        {user_id: current_user.id, platform: platform}
      )
    )
    if @ec2_instance.save
      message = Wonga::Pantry::BootMessage.new(@ec2_instance)
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
    params.require(:ec2_instance).permit(:name, :team_id, :user_id, :ami, :flavor, :subnet_id, :security_group_ids, :domain, :chef_environment, :run_list, :platform)
  end
end

