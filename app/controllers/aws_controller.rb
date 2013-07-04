class AwsController < ApplicationController

  def create
  end

  def save
    server = aws.servers.create({
      flavor_id: "t1.micro",
      image_id: "ami-fedfd48a"
    }) 
    aws.tags.create(
      :resource_id => server.identity,
      :key => 'Name',
      :value => params["instance"]["name"]
    )
    redirect_to ec2_url
  end

  def aws
     Fog::Compute.new(:provider=>'AWS')
  end
  
  def ec2s
    @lists = aws.servers
  end
  
  def amis 
    my_images_raw = aws.describe_images('Owner' => 'self')
    @lists = my_images_raw.body["imagesSet"]
  end

  def vpcs
    @lists = aws.vpcs
  end

  def security_groups
    @lists = aws.security_groups
  end
  
end
