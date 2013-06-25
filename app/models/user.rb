class User < ActiveRecord::Base
  attr_accessible :email, :username
  has_many :team_members
  has_many :teams, through: :team_members
end
