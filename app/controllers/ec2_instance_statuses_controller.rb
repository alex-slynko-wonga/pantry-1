class Ec2InstanceStatusesController < ApplicationController
  
  def show
    @ec2_instance = Ec2Instance.find params[:id]
    @statuses = {}
    [@ec2_instance.joined, @ec2_instance.booted, @ec2_instance.bootstrapped].each{|i| 
      if i
      	@statuses[i] = "awstick.png"
      else
      	@statuses[i] = "spinner.gif"
      end
    }
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @ec2_instance }
    end
  end
end
