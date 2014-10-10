class InstanceRole < ActiveRecord::Base
  belongs_to :ami
  has_many :ec2_volumes, inverse_of: :instance_role
  accepts_nested_attributes_for :ec2_volumes, allow_destroy: true

  validates :ami, presence: true
  validates :chef_role, presence: true
  validates :ec2_volumes, presence: true
  validates :instance_size, presence: true
  validates :name, presence: true, uniqueness: true
  validates :run_list, chef_run_list_format: true
  validates :security_group_ids, security_group_ids_limit: true

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
    instance_ec2_volumes = ec2_volumes.map do |volume|
      new_volume = volume.dup
      new_volume.instance_role = nil
      new_volume
    end

    {
      flavor: instance_size,
      ami: ami.ami_id,
      run_list: full_run_list,
      security_group_ids: security_group_ids,
      instance_role: self,
      platform: ami.platform,
      ec2_volumes: instance_ec2_volumes,
      iam_instance_profile: iam_instance_profile
    }
  end

  def update_volumes(new_volumes)
    new_volumes.each do |new_volume|
      old_volume = ec2_volumes.detect do |saved_volume|
        saved_volume.device_name == new_volume.device_name
      end

      if old_volume
        old_volume.volume_type = new_volume.volume_type
        old_volume.snapshot = new_volume.snapshot
        old_volume.size = new_volume.size if old_volume.size < new_volume.size
      else
        ec2_volumes << new_volume
      end
    end
  end

  private

  def check_security_group_ids
    self.security_group_ids = security_group_ids.uniq.reject(&:empty?) if security_group_ids
  end
end
