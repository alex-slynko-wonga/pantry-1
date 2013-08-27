class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :jenkins_server
  has_one :team, through: :jenkins_server
  
  validates :ec2_instance, :jenkins_server, presence: true
end
