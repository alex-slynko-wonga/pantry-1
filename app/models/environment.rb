class Environment < ActiveRecord::Base
  has_many :ec2_instance
  belongs_to :team
  validates_uniqueness_of :name, scope: :team_id
end
