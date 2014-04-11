class JenkinsServer < ActiveRecord::Base
  belongs_to :team
  belongs_to :ec2_instance, inverse_of: :jenkins_server
  has_many :jenkins_slaves, -> { where(removed: [false, nil]) }

  default_scope -> { eager_load(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.not_terminated) }

  validates :team, presence: true
  validates :ec2_instance, presence: true
  validate :team_cannot_own_multiple_servers, on: :create
  validates_with CIInstanceValidator

  def instance_name
    self.team.jenkins_host_name
  end

  private
  def team_cannot_own_multiple_servers
    unless JenkinsServer.joins(:ec2_instance).merge(Ec2Instance.not_terminated).where(team_id: team_id).count.zero?
      errors.add(:team, "can't own multiple servers")
    end
  end
end
