class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :jenkins_server
  has_one :team, through: :jenkins_server
  
  validates :ec2_instance, :jenkins_server, presence: true
  
  before_validation :set_ec2_instance_name
  
  def set_ec2_instance_name
    counter = JenkinsSlave.count
    raise 'There are too many Jenkins Slaves to generate a number lower than 15 characters' if counter > 99999999
    padding = '0' * (15 - ('agent-'.length + (counter + 1).to_s.length))
    ec2_instance.name = "agent-#{padding}#{JenkinsSlave.count + 1}" if ec2_instance
  end
end
