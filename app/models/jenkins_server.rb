class JenkinsServer < ActiveRecord::Base
  validates :team, presence: true
  validates :ec2_instance, presence: true
  belongs_to :team
  has_many :jenkins_slaves
  has_one :ec2_instance
  belongs_to :ec2_instance

  validate :team_cannot_own_multiple_servers, :on => :create

  def team_cannot_own_multiple_servers
  	unless JenkinsServer.find_by_team_id(self.team_id).nil?
      errors.add(:team, "can't own multiple servers")
    end
  end

end
