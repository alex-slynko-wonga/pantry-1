class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances
  has_one :jenkins_server

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true, if: 'chef_environment'

  def jenkins_host_name
    self.chef_environment[0...63]
  end

  def create_environment_message(team)
    {
      team_name:          team.name,
      domain:             domain = CONFIG['pantry']['domain'],
    }
  end
end
