class Aws::Ec2InstanceController < ApplicationController
  def new
    @ec2_instance = Ec2Instance.new
  end

  def create
  end
end
