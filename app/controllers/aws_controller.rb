class AwsController < ApplicationController

  def aws
    AWS::EC2.new
  end
  
  def ec2s
    @lists = aws.instances.to_a
  end

  def amis
    @lists = aws.images.with_owner('self').to_a
  end

  def vpcs
    @lists = aws.vpcs
  end

  def security_groups
    @lists = aws.security_groups
  end
  
end
