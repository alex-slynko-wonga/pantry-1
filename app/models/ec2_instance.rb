class Ec2Instance < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  belongs_to :environment
  has_one :jenkins_server
  has_one :jenkins_slave
  has_many   :ec2_instance_costs
  has_many   :ec2_instance_logs

  validates :name, uniqueness: { scope: [:terminated] }, unless: 'terminated?'
  validate :winbind_compatibility, unless:'terminated?'
  validates :name, presence: true
  validates :name, length: { maximum: 15 }, if: 'platform == "windows"'
  validates :name, length: { maximum: 63 }, if: 'platform == "linux"'
  validate  :name_rfc1123
  validates :team, presence: true
  validates :user, presence: true
  validates :domain, presence: true, domain_name: true
  validates :run_list, presence: true, chef_run_list_format: true
  validates :ami, presence: true
  validates :environment, presence: true
  validates :volume_size, presence: true
  validates :flavor, presence: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true
  validate  :check_user_team, on: :create
  validate  :jenkins_slave_is_ok, on: :create
  validate  :jenkins_server_is_ok, on: :create
  validate  :check_environment_team, on: :create
  validates :state, presence: true
  validates :ip_address, presence: true, if: :was_booted?
  validates :instance_id, presence: true, if: :was_booted?
  validates :platform, presence: true

  serialize :security_group_ids

  before_validation :set_platform_security_group_id
  after_initialize :init, on: :create
  before_validation :check_security_group_ids
  before_validation :set_volume_size, on: :create


  scope :terminated, -> { where(state: 'terminated') }
  scope :not_terminated, -> { where.not(state: 'terminated') }

  def name_rfc1123
    hostname_regex = /\A[a-zA-Z]+[a-zA-Z0-9-]*[a-zA-Z0-9]+\Z/
    errors.add(:name, "Only alphanumeric and hyphens are allowed (see rfc1123)") unless name && name[hostname_regex]
  end

  def check_security_group_ids
    self.security_group_ids.reject! { |i| i.empty? } if self.security_group_ids
  end

  def human_status
    state.humanize
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
    self.security_group_ids = Array(self.security_group_ids)
    if self.platform == 'windows'
      self.security_group_ids << CONFIG['aws']['security_group_windows']
    else
      self.security_group_ids << CONFIG['aws']['security_group_linux']
    end
    self.security_group_ids.uniq!
  end

  def check_user_team
    return unless self.user && self.team
    errors.add(:team_id, "Current user is not in this team.") unless self.user.teams.include?(self.team)
  end

  def check_environment_team
    return unless self.team && self.environment
    errors.add(:environment_id, "Environment is not from this team") unless self.environment.team_id == self.team_id
    errors.add(:environment_id, "Environment is not ready to be used") if self.environment.chef_environment.blank?
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

    if Ec2Instance.where("name like ?", name[0, 14] + '%').where.not(id: id).not_terminated.exists?
      errors.add(:name, "The first 15 characters (#{name[0, 14]}) are not unique. This constraint is required to join the Active Directory")
    end
  end
end
