class Team < ActiveRecord::Base
  has_many :ec2_instance_costs, through: :ec2_instances
  has_many :ec2_instances
  has_many :environments
  has_many :schedules
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_one :ci_environment, -> { where environment_type: 'CI' }, class_name: 'Environment'
  has_one :jenkins_server

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true, if: 'chef_environment'

  scope :with_ci_environment, -> { joins(:environments).where(environments: { environment_type: 'CI' }).where.not(environments: { chef_environment: nil }) }
  scope :without_jenkins, -> { order(:name).select { |team| JenkinsServer.where(team_id: team.id).count == 0 } }

  scope :active, -> { where(disabled: [nil, false]).order(:name) }
  scope :inactive, -> { where(disabled: true).order(:name) }

  def jenkins_host_name
    name.parameterize.gsub('_', '-').gsub('--', '-')[0..62]
  end
end
