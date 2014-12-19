class Environment < ActiveRecord::Base
  TYPES = %w(CI INT RC STG WIP CUSTOM)

  has_many :ec2_instances
  has_many :running_ec2_instances, -> { not_terminated }, class_name: 'Ec2Instance'
  belongs_to :team

  validates :name, uniqueness: { scope: :team_id }, presence: true
  validates :chef_environment, uniqueness: { scope: :team_id, if: 'chef_environment' }, presence: { on: :update }
  validates :environment_type, inclusion: { in: TYPES }, presence: true
  validates :team, uniqueness: { scope: :environment_type, if: "environment_type == 'CI'" }, presence: true

  scope :available, -> { where.not(chef_environment: nil) }
  scope :available_for_user, ->(user) { available.where(team_id: user.team_ids).where.not(environment_type: 'CI') }
  scope :visible, -> { where(hidden: [false, nil]) }
  scope :invisible, -> { where(hidden: true) }

  validate :can_hide, on: :update

  accepts_nested_attributes_for :team

  def team_name
    attributes['team_name'] || team.name
  end

  def human_name
    "#{name} (#{environment_type})"
  end

  def can_hide
    return unless hidden_changed?
    return if ec2_instances.all? { |instance| instance.state == 'terminated' }

    errors.add(:environment_id, 'Environment can not be hidden due to non-terminated instances')
  end

  def hide
    update_attributes(hidden: true)
  end

  def self.group_by_team_name
    @result = order('teams.name', :name).joins(:team).select('teams.name as team_name', 'environments.name', 'environments.id').to_a.group_by(&:team_name)
  end
end
