class Environment < ActiveRecord::Base
  TYPES = ["CI", "INT", "RC", "STG", "WIP", "CUSTOM"]

  has_many :ec2_instances
  belongs_to :team

  delegate :name, to: :team, prefix: true

  validates_uniqueness_of :name, scope: :team_id
  validates :chef_environment, uniqueness: { scope: :team_id, if: 'chef_environment'}, presence: {on: :update}
  validates_presence_of :name
  validates :environment_type, inclusion: { in: TYPES }, presence: true
  validates :team, uniqueness: { scope: :environment_type, if: "environment_type == 'CI'" }, presence: true

  scope :available, ->(user) { where.not(chef_environment: nil).where(team_id: user.team_ids) }

  accepts_nested_attributes_for :team

  def human_name
    "#{self.name} (#{self.environment_type})"
  end
end
