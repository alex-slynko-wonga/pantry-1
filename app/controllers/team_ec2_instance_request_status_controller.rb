class TeamEc2InstanceRequestStatusController < ApplicationController

  def index
    @ec2instances = Ec2Instance.where('team_id = ?', params[:team_id].to_i)
  end

end
