class JenkinsServer < ActiveRecord::Base
  belongs_to :team
  has_many :jenkins_slaves, -> { where(removed: [false, nil]) }
  belongs_to :ec2_instance
  default_scope -> { eager_load(:ec2_instance).references(:ec2_instance).merge(Ec2Instance.running) }

  accepts_nested_attributes_for :ec2_instance

  validates :team, presence: true
  validates :ec2_instance, presence: true
  validate :team_cannot_own_multiple_servers, on: :create

  def instance_name
    self.team.jenkins_host_name
  end

  private
  def team_cannot_own_multiple_servers
    unless JenkinsServer.joins(:ec2_instance).merge(Ec2Instance.running).where(team_id: team_id).count.zero?
      errors.add(:team, "can't own multiple servers")
    end
  end
end
