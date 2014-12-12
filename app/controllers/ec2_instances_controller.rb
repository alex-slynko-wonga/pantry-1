class Ec2InstancesController < ApplicationController
  def aws_status
    @ec2_instance_status = Ec2InstanceStatus.find(params[:id])
    respond_to do |format|
      format.json { render }
    end
  end

  def show
    @ec2_instance = Ec2Instance.find params[:id]
    respond_to do |format|
      format.html { render layout: false }
      format.json { render }
    end
  end

  def index
    @ec2_instances = Ec2Instance.all
  end
end
