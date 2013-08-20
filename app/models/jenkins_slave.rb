class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :jenkins_server
  has_one :team, through: :jenkins_server
end
