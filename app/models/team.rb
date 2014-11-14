class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances
  has_many :ec2_instance_costs, through: :ec2_instances
  has_many :environments
  has_one :jenkins_server
  has_one :ci_environment, -> { where environment_type: 'CI' }, class_name: 'Environment'

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true, if: 'chef_environment'

  scope :with_environment, -> { joins(:environments).where.not(environments: { chef_environment: nil }) }
  scope :without_jenkins, lambda {
    joins('LEFT OUTER JOIN jenkins_servers on jenkins_servers.team_id = teams.id')
       .joins('LEFT OUTER JOIN ec2_instances on ec2_instances.id = jenkins_servers.ec2_instance_id')
       .where('ec2_instances.terminated = 1  or jenkins_servers.id is null')
  }

  scope :active, -> { where(disabled: [nil, false]).order(:name) }
  scope :inactive, -> { where(disabled: true).order(:name) }

  def jenkins_host_name
    name.parameterize.gsub('_', '-').gsub('--', '-')[0..62]
  end
end
