class InstanceRole < ActiveRecord::Base
  belongs_to :ami

  validates :ami, presence: true
  validates :chef_role, presence: true
  validates :instance_size, presence: true
  validates :name, presence: true, uniqueness: true
  validates :run_list, chef_run_list_format: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true

  serialize :security_group_ids

  before_validation :check_security_group_ids

  scope :enabled, -> { where(enabled: true) }
  scope :for, lambda { |instance|
    case instance
    when JenkinsServer
      where("name LIKE '%Jenkins Server%'")
    when JenkinsSlave
      where("name LIKE '%Jenkins Agent%'")
    else
      self
    end
  }

  def display_name
    enabled ? name : name + ' (disabled)'
  end

  def full_run_list
    run_list.blank? ? "role[#{chef_role}]" : "role[#{chef_role}],#{run_list}"
  end

  def instance_attributes
    {
      flavor: instance_size,
      ami: ami.ami_id,
      run_list: full_run_list,
      security_group_ids: security_group_ids,
      instance_role: self,
      volume_size: disk_size,
      platform: ami.platform,
      iam_instance_profile: iam_instance_profile
    }
  end

  private

  def check_security_group_ids
    self.security_group_ids = security_group_ids.uniq.reject(&:empty?) if security_group_ids
  end
end
