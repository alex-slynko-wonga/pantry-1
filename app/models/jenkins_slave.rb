class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :jenkins_server

  accepts_nested_attributes_for :ec2_instance

  validates :ec2_instance, :jenkins_server, presence: true
  validate :team_should_be_same_as_jenkins_server

  before_validation :set_ec2_instance_name

  def team
    jenkins_server.try(:team)
  end

  def instance_name
    counter = JenkinsSlave.last.try(:id) || 0
    errors.add(:ec2_instance, 'There are too many Jenkins Slaves to generate a number lower than 15 characters') and return if counter > 99999999
    "agent-#{"%09d" % (counter + 1)}"
  end

  private
  def set_ec2_instance_name
    ec2_instance.name = instance_name if ec2_instance
  end

  def team_should_be_same_as_jenkins_server
    errors.add(:team, 'should be the same for Ec2Instance and Jenkins') if jenkins_server && ec2_instance && jenkins_server.team != ec2_instance.team
  end
end
