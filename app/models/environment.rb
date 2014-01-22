class Environment < ActiveRecord::Base
  has_many :ec2_instances
  belongs_to :team
  validates_uniqueness_of :name, :chef_environment, scope: :team_id
  validates_presence_of :name, :chef_environment, :team
end
