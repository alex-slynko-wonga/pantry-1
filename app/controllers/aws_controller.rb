class AwsController < ApplicationController

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
