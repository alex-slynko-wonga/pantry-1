class Ec2Instance < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  belongs_to :environment
  has_one :jenkins_server
  has_one :jenkins_slave
  has_many   :ec2_instance_costs
  has_many   :ec2_instance_logs

  validates :name, uniqueness: { scope: [:terminated] }, unless: 'terminated?'
  validates :name, presence: true
  validates :name, length: { maximum: 15 }, if: 'platform == "windows"'
  validates :name, length: { maximum: 63 }, if: 'platform == "linux"'
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
  validate  :check_environment_team
  validates :state, presence: true

  serialize :security_group_ids

  before_validation :set_platform_security_group_id
  after_initialize :init, on: :create
  before_validation :check_security_group_ids
  before_validation :set_volume_size, on: :create

  accepts_nested_attributes_for :jenkins_server
  accepts_nested_attributes_for :jenkins_slave
  accepts_nested_attributes_for :environment

  scope :terminated, -> { where(state: 'terminated') }
  scope :not_terminated, -> { where.not(state: 'terminated') }

  def check_security_group_ids
    self.security_group_ids.reject! { |i| i.empty? } if self.security_group_ids
  end

  def human_status
    state ? state.humanize : "Initial state"
  end

  private
  def init
    self.domain       ||= CONFIG['pantry']['domain']
    self.subnet_id    ||= CONFIG['aws']['default_subnet']
    self.instance_id  ||= "pending"
    self.ip_address   ||= "pending"
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
end
