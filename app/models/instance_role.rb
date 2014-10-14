class InstanceRole < ActiveRecord::Base
  belongs_to :ami

  validates :name, presence: true, uniqueness: true
  validates :ami, presence: true
  validates :security_group_ids, presence: true, security_group_ids_limit: true
  validates :chef_role, presence: true
  validates :run_list, chef_run_list_format: true
  validates :instance_size, presence: true
  validates :disk_size, presence: true

  scope :enabled, -> { where(enabled: true) }

end
