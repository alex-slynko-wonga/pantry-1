class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances
  has_one :jenkins_server

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true, if: 'chef_environment'

  scope :with_environment, -> { where('teams.chef_environment IS NOT NULL') }
  scope :without_jenkins, -> { includes(jenkins_server: :ec2_instance).where('ec2_instances.terminated = 1  or jenkins_servers.id is null') }

  def jenkins_host_name
    self.chef_environment[0...63]
  end
end
