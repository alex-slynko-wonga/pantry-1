class Ec2Instance < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  belongs_to :terminated_by, class_name: 'User'
  has_many   :ec2_instance_costs
  has_many   :ec2_instance_logs
  belongs_to :environment

  validates :name, uniqueness: { scope: [:terminated] }, unless: 'terminated?'
  validates :name, presence: true
  validates :name, length: { maximum: 15 }, if: 'platform == "windows"'
  validates :name, length: { maximum: 63 }, if: 'platform == "linux"'
  validates :team, presence: true
  validates :user, presence: true
  validates :domain, presence: true, domain_name: true
  validates :chef_environment, presence: true
  validates :run_list, presence: true, chef_run_list_format: true
  validates :ami, presence: true
  validates :volume_size, presence: true
  validates :flavor, presence: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true
  validate  :check_user_team, on: :create
  validates :state, presence: true

  serialize :security_group_ids

  before_validation :set_platform_security_group_id
  after_initialize :init, on: :create
  before_validation :check_security_group_ids
  before_create :set_start_time
  before_validation :set_volume_size, on: :create

  scope :terminated, -> { where(terminated: true) }
  scope :running, -> { where(terminated: [false, nil]) }

  def check_security_group_ids
    self.security_group_ids.reject! { |i| i.empty? } if self.security_group_ids
  end

  def human_status
    state ? state.humanize : "Initial state"
  end

  def progress
    return 100 if bootstrapped && joined
    if bootstrapped
      40
    elsif joined
      60
    elsif booted
      20
    else
      0
    end
  end

  private
  def init
    self.domain       ||= CONFIG['pantry']['domain']
    self.subnet_id    ||= CONFIG['aws']['default_subnet']
    self.instance_id  ||= "pending"
    self.ip_address   ||= "pending"
    Wonga::Pantry::Ec2InstanceMachine.new(self)
  end

  def set_start_time
    self.start_time = Time.current
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
end
