class Ec2Instance < ActiveRecord::Base
  belongs_to :environment
  belongs_to :instance_role
  belongs_to :team
  belongs_to :user
  has_one :instance_schedule
  has_one :jenkins_server, validate: true
  has_one :jenkins_slave, validate: true
  has_many :ec2_instance_costs
  has_many :ec2_instance_logs
  has_many :ec2_volumes, inverse_of: :ec2_instance
  has_many :schedules, through: :instance_schedule
  has_one :scheduled_event

  validates :ami, presence: true
  validates :domain, presence: true, domain_name: true
  validates :environment, presence: true
  validates :flavor, presence: true
  validates :instance_id, presence: true, if: :was_booted?
  validates :ip_address, presence: true, if: :was_booted?
  validates :name, length: { maximum: 14, too_long: 'Name must be <= 14 characters for MSDTC in Windows platform' }, if: 'platform == "windows"', on: :create
  validates :name, length: { maximum: 63 }, if: 'platform == "linux"'
  validates :name, presence: true, format: /\A[a-zA-Z]+[a-zA-Z0-9-]*[a-zA-Z0-9]+\Z/
  validates :name, uniqueness: { scope: [:terminated] }, unless: 'terminated?'
  validates :platform, presence: true
  validates :run_list, presence: true, chef_run_list_format: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true
  validates :state, presence: true
  validates :team, presence: true
  validates :user, presence: true
  validates :ec2_volumes, presence: true, on: :create

  validate :check_environment_team, on: :create
  validate :winbind_compatibility, unless: 'terminated?'

  serialize :security_group_ids

  accepts_nested_attributes_for :ec2_volumes
  accepts_nested_attributes_for :scheduled_event

  after_initialize :init, on: :create
  before_validation :set_platform_security_group_id, on: :create
  before_validation :set_volume_size, on: :create
  after_validation :set_schedule, on: :create

  scope :terminated, -> { where(state: 'terminated') }
  scope :not_terminated, -> { where.not(state: 'terminated') }

  attr_writer :additional_volume_size

  def human_status
    state.humanize
  end

  def additional_volume_size
    @additional_volume_size || ec2_volumes[1].try(:size)
  end

  def update_info(ec2_instance_info = nil)
    return if self.terminated?
    updater = Wonga::Pantry::Ec2InstanceUpdateInfo.new(self, ec2_instance_info)
    # Phase1: update attributes
    attr = updater.update_attributes
    # Phase2: Determine state change(s) needed, if any
    state = updater.update_state
    (attr && state)
  end

  def initialize_dup(other)
    super
    [:instance_id, :team_id, :created_at, :updated_at, :user_id, :bootstrapped, :joined, :terminated, :ip_address, :dns, :state].each do |attribute|
      self[attribute] = nil
    end
  end

  def schedule_next_event
    return unless instance_schedule
    if state == 'ready'
      event = scheduled_event || build_scheduled_event
      event.event_type = 'shutdown'
      event.event_time = instance_schedule.next_shutdown_time
    elsif state == 'shutdown_automatically'
      event = scheduled_event || build_scheduled_event
      event.event_type = 'start'
      event.event_time = instance_schedule.next_start_time
    end
  end

  private

  def init
    self.domain       ||= CONFIG['pantry']['domain']
    self.subnet_id    ||= CONFIG['aws']['default_subnet']
    Wonga::Pantry::Ec2InstanceMachine.new(self)
  end

  def set_volume_size
    self.volume_size ||= CONFIG['aws']['ebs'][flavor]
  end

  def set_platform_security_group_id
    self.security_group_ids = Array(security_group_ids)
    if platform == 'windows'
      security_group_ids << CONFIG['aws']['security_group_windows']
    else
      security_group_ids << CONFIG['aws']['security_group_linux']
    end
    self.security_group_ids = security_group_ids.uniq.reject(&:empty?)
  end

  def check_environment_team
    return unless team && environment

    errors.add(:environment_id, 'Environment is not from this team') unless environment.team_id == team_id
    errors.add(:environment_id, 'Environment is not ready to be used') if environment.chef_environment.blank?
  end

  def was_booted?
    state != 'initial_state' && state != 'booting'
  end

  def winbind_compatibility
    return unless name
    return unless name.size > 15 # otherwise use Rails uniqueness validation
    return unless Ec2Instance.where('name like ?', name[0, 14] + '%').where.not(id: id).not_terminated.exists?

    errors.add(:name, "The first 15 characters (#{name[0, 14]}) are not unique. This constraint is required to join the Active Directory")
  end

  def set_schedule
    return unless team
    team_schedule = team.schedules.daily.first
    build_instance_schedule(schedule: team_schedule) if team_schedule
  end
end
