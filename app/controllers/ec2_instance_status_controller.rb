class Ec2InstanceStatusController < ApplicationController
  
  def show
    @ec2_instance = Ec2Instance.find params[:id]
    render layout: false
  end
end
