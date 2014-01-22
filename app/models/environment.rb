class Environment < ActiveRecord::Base
  has_many :ec2_instances
  belongs_to :team
  validates_uniqueness_of :name, :chef_environment, scope: :team_id
  validate :only_one_ci_env_type_per_team
  validates_presence_of :name, :chef_environment, :team, :environment_type

  TYPES = ["CI", "INT", "RC", "STG", "WIP"]

  def only_one_ci_env_type_per_team
    if Environment.where("team_id = ? AND  environment_type = 'CI'", team_id).count > 0
      errors.add(:environment_type, 'Only one CI type is allowed per team')
    end
  end
end
