class JenkinsSlave < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :jenkins_server
  has_one :team, through: :jenkins_server
  
  def self.ec2_instances(jenkins_slaves)
    Ec2Instance.where("id IN(?)", jenkins_slaves.collect(&:id))
  end
end
