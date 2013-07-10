class Aws::Ec2InstancesController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
    fog = Fog::Compute.new(provider: 'AWS')
    amis = fog.describe_images("Owner" => "self").body["imagesSet"]
    @ami_options = {}
    amis.each{|ami|
      @ami_options[ami["name"]] = ami["imageId"]
    }
    @flavor_options = {
      't1.micro' => 't1.micro'
    }
    teams = Team.all
    @team_options = {}
    teams.each{|team|
      @team_options[team[:name]] = team[:name]
    }
  end

  def create
    ec2_params = {
      name: params["ec2_instance"][:name],
      team_id: params["ec2_instance"][:team_id],
      instance_id: "pending",
      status: "pending"
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
      redirect_to "/aws/ec2s/"
    else
      render :new
    end
  end

  private

  def ec2_instance_params
    params.require(:name, :team_id).permit(:instance_id, :status)
  end

end
