class Ec2InstanceStatusesController < ApplicationController
  
  def show
    @ec2_instance = Ec2Instance.find params[:id]
    @statuses = {}
    states = [@ec2_instance.booted, @ec2_instance.bootstrapped, @ec2_instance.joined]
    states.each_with_index{|item, i| 
      if item
      	@statuses[i] = "awstick.png"
      else
      	@statuses[i] = "spinner.gif"
      end
    }
    puts @statuses
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: @ec2_instance }
    end
  end
end
