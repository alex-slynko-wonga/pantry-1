class Aws::Ec2InstancesController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
    fog = Fog::Compute.new(provider: 'AWS')
    amis = fog.describe_images("Owner" => "self").body["imagesSet"]
    @ami_options = amis.each_with_object({}) do |ami, ami_options|
      ami_options[ami["name"]] = ami["imageId"]
    end
    @flavor_options = {
      't1.micro' => 't1.micro'
    }
  end

  def create
    ec2_params = {
      name: params["ec2_instance"][:name],
      team_id: params["ec2_instance"][:team_id],
      user_id: current_user.id,
      ami: params["ec2_instance"][:ami],
      flavor: params["ec2_instance"][:flavor]
    }
    ec2_instance = Ec2Instance.new(ec2_params)
    if ec2_instance.save
      #
      #  Call delayed_job method from here
      #  when complete.
      #
      #  Delayed::Job.enqueue NAMEOFEC2JOB.new(
      #    ec2_instance.id,
      #    params["ec2_instance"][:name],
      #    params["ec2_instance"][:flavor],
      #    params["ec2_instance"][:ami],
      #    params["ec2_instance"][:team]
      #  )
      #  ec2_instance.start!(instance_id)
      redirect_to "/aws/ec2s/"
    else
      render :new
    end
  end

  private

  def ec2_instance_params
    params.require(:name, :team_id, :user_id).permit(:instance_id, :team_id, :user_id, :ami, :flavor)
  end

end
