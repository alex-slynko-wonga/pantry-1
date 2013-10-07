class Ec2Instance < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :name, presence: true, uniqueness: true, length: { maximum: 15 }
  validates :team, presence: true
  validates :user, presence: true
  validates :domain, :presence => true, :domain_name => true
  validates :chef_environment, :presence => true
  validates :run_list, :presence => true, :chef_run_list_format => true
  validates :ami, presence: true
  validates :volume_size, presence: true
  validates :flavor, presence: true
  validates :security_group_ids, :presence => true, :security_group_ids_limit => true
  validate  :check_user_team
  
  serialize :security_group_ids

  before_validation :set_platform_security_group_id
  after_initialize :init, on: :create
  before_validation :check_security_group_ids
  before_create :set_start_time
  before_validation :set_volume_size, on: :create
  
  def check_user_team
    errors.add(:team_id, "Current user is not in this team.") unless self.user.teams.include?(self.team)
  end
  
  def chef_node_delete
    update_attributes(bootstrapped: false)
  end

  def check_security_group_ids
    self.security_group_ids.reject! { |i| i.empty? } if self.security_group_ids
  end

  def exists!(instance_id)
    self.instance_id = instance_id
    self.save!
  end

  def complete!(status)
    case status
    when :booted
      self.booted = true
    when :bootstrapped
      self.bootstrapped = true
    when :joined
      self.joined = true
      self.end_time = Time.current
    end
    save!
  end

  def human_status
    return "Ready" if bootstrapped && joined
    if bootstrapped
      "Bootstrapped"
    elsif joined
      "Joined to domain"
    elsif booted
      "Booted"
    else
      "Booting"
    end
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
    self.booted ||= false
    self.bootstrapped ||= false
    self.joined ||= false
    self.domain       ||=  CONFIG['pantry']['domain']
    self.subnet_id    ||=  CONFIG['aws']['default_subnet']
    self.instance_id  ||=  "pending"
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
end
