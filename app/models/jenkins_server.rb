class JenkinsServer < ActiveRecord::Base
  validates :team, presence: true
  validates :ec2_instance_id, presence: true
  belongs_to :team
  has_many :jenkins_slaves
  has_one :ec2_instance
  belongs_to :ec2_instance
end
