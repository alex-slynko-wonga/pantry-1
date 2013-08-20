class JenkinsSlave < ActiveRecord::Base
  attr_accessible :jenkins_server_id, :ec2_instance_id
  
  belongs_to :ec2_instance
  belongs_to :jenkins_server
  
  def team
    jenkins_server.team
  end
end
