class Aws::Ec2InstanceController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
  end

  def create
  	Fog.mock!
  	fog = Fog::Compute.new(provider: 'AWS')
  	server = fog.servers.create({
  		flavor_id: "t1.micro",
  		image_id: "ami-fedfd48a"
  	})
  	fog.tags.create(
  		:resource_id => server.identity,
  		:key => 'Team',
  		:value => params["ec2_instance"]["name"]
  	)
  	server.reload.tags
  	puts server
  	redirect_to "/aws/ec2_instance/new"
  end
end
