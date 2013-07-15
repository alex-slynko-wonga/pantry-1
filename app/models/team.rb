class Team < ActiveRecord::Base
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
  has_many :ec2_instances

  validates :name, presence: true
end
