class Ec2Volume < ActiveRecord::Base
  TYPES = { 'standard' => 'Standard', 'io1' => 'IO optimized', 'gp2' => 'SSD' }
  belongs_to :ec2_instance, inverse_of: :ec2_volumes
  belongs_to :instance_role, inverse_of: :ec2_volumes

  validates :ec2_instance, presence: { if: 'instance_role.blank?' }, absence: { if: 'instance_role.present?' }
  validates :instance_role, presence: { if: 'ec2_instance.blank?' }, absence: { if: 'ec2_instance.present?' }
  validates :size, presence: true, numericality: { greater_than_or_equal_to: 30, less_than_or_equal_to: 1000 }
  validates :snapshot, length: { maximum: 13 }, format: { with: /\Asnap\-[a-f0-9]+\Z/ }, if: :snapshot?
  validates :volume_type, length: { maximum: 8 }, presence: true, inclusion: { in: TYPES.keys }
  validates :device_name, length: { maximum: 10 }, presence: true, uniqueness: { scope: [:ec2_instance_id, :instance_role_id] }

  before_validation :set_volume_type, on: :create

  def display_type
    TYPES[volume_type]
  end

  private

  def set_volume_type
    self.volume_type ||= TYPES.first
  end
end
