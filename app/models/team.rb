class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances
  has_one :jenkins_server

  after_initialize :init, on: :create 

  validates :name, presence: true, uniqueness: true
  validates :chef_environment, uniqueness: true, on: :update

  def jenkins_host_name
    self.chef_environment[0...63]
  end

  def create_environment_message
    {
      team_name:          self.name,
      domain:             domain = CONFIG['pantry']['domain'],
    }
  end

  def init
    self.chef_environment ||= "pending"
  end
end
