class Ec2InstanceStatusesController < ApplicationController
  def show
    @ec2_instance = Ec2Instance.find params[:id]
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @ec2_instance }
    end
  end
end
