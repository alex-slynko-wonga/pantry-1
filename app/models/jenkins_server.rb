class JenkinsServer < ActiveRecord::Base
  belongs_to :team
  has_many :jenkins_slaves
  belongs_to :ec2_instance

  accepts_nested_attributes_for :ec2_instance

  validates :team, presence: true
  validates :ec2_instance, presence: true
  validate :team_cannot_own_multiple_servers, on: :create

  def instance_name
    self.team.jenkins_host_name
  end

  private
  def team_cannot_own_multiple_servers
    unless JenkinsServer.find_by_team_id(self.team_id).nil?
      errors.add(:team, "can't own multiple servers")
    end
  end
end
