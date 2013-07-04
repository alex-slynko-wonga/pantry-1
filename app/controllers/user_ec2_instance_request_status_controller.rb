class UserEc2InstanceRequestStatusController < ApplicationController
  
  def index
    @ec2instances = Ec2Instance.where('user_id = ?', current_user.user_id.to_i)
  end
  
end
