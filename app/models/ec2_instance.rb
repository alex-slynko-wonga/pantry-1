class Ec2Instance < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  belongs_to :environment
  belongs_to :instance_role
  has_one :jenkins_server
  has_one :jenkins_slave
  has_many :ec2_instance_costs
  has_many :ec2_instance_logs

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

  validate :check_environment_team, on: :create
  validate :jenkins_server_is_ok, on: :create
  validate :jenkins_slave_is_ok, on: :create
  validate :winbind_compatibility, unless: 'terminated?'

  serialize :security_group_ids

  after_initialize :init, on: :create
  before_validation :set_platform_security_group_id, on: :create
  before_validation :set_volume_size, on: :create

  scope :terminated, -> { where(state: 'terminated') }
  scope :not_terminated, -> { where.not(state: 'terminated') }

  def human_status
    state.humanize
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

  def jenkins_server_is_ok
    return unless jenkins_server
    errors.add(:jenkins_server, jenkins_server.errors.full_messages.to_sentence) if jenkins_server.invalid?
  end

  def jenkins_slave_is_ok
    return unless jenkins_slave
    errors.add(:jenkins_slave, jenkins_slave.errors.full_messages.to_sentence) if jenkins_slave.invalid?
  end

  def winbind_compatibility
    return unless name
    return unless name.size > 15 # otherwise use Rails uniqueness validation
    return unless Ec2Instance.where('name like ?', name[0, 14] + '%').where.not(id: id).not_terminated.exists?

    errors.add(:name, "The first 15 characters (#{name[0, 14]}) are not unique. This constraint is required to join the Active Directory")
  end
end
