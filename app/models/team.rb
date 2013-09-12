class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances
  has_one :jenkins_server

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true

  def jenkins_host_name
    self.chef_environment[0...63]
  end
end
