class Ec2InstanceStatusesController < ApplicationController
  def show
    @ec2_instance = Ec2Instance.find params[:id]
    @ec2_statuses = {
    	booted: @ec2_instance.booted,
    	bootstrapped: @ec2_instance.bootstrapped,
    	joined: @ec2_instance.joined
    }
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @ec2_instance }
    end
  end
end
