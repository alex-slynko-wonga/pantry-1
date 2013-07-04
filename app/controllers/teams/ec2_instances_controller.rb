class Teams::Ec2InstancesController < ApplicationController
  respond_to :json
  def index
    respond_with Ec2Instance.all
  end
end
