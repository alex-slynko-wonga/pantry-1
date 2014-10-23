class InstanceRole < ActiveRecord::Base
  belongs_to :ami

  validates :name, presence: true, uniqueness: true
  validates :ami, presence: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true
  validates :chef_role, presence: true
  validates :run_list, chef_run_list_format: true
  validates :instance_size, presence: true
  validates :disk_size, presence: true

  serialize :security_group_ids

  before_validation :check_security_group_ids

  scope :enabled, -> { where(enabled: true) }

  def display_name
    self.enabled ? self.name : self.name + ' (disabled)'
  end

  def check_security_group_ids
    self.security_group_ids = self.security_group_ids.uniq.reject { |i| i.empty? } if self.security_group_ids
  end

  def full_run_list
    self.run_list.blank? ? "role[#{self.chef_role}]" : "role[#{self.chef_role}]," + self.run_list
  end
end
