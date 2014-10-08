class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance, inverse_of: :jenkins_slave
  belongs_to :jenkins_server

  validates :ec2_instance, :jenkins_server, presence: true
  validate :team_should_be_same_as_jenkins_server
  validates_with CIInstanceValidator

  accepts_nested_attributes_for :ec2_instance

  before_validation :set_ec2_instance_name, on: :create

  def team
    jenkins_server.try(:team)
  end

  def instance_name
    counter = JenkinsSlave.last.try(:id) || 0
    "agent-#{"%08d" % (counter + 1)}"
  end

  private
  def set_ec2_instance_name
    ec2_instance.name = instance_name if ec2_instance
  end

  def team_should_be_same_as_jenkins_server
    errors.add(:team, 'should be the same for Ec2Instance and Jenkins') if jenkins_server && ec2_instance && jenkins_server.team != ec2_instance.team
  end
end
