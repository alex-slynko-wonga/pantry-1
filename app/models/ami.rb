class Ami < ActiveRecord::Base
  PLATFORM = %w( windows linux )

  validates :ami_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :platform, inclusion: PLATFORM, presence: true

  validate :check_platform_changed, on: :update

  scope :visible, -> { where(hidden: [false, nil]) }

  def self.group_by_platform
    order(:name).pluck(:platform, :name, :ami_id).each_with_object({}) do |(platform, name, ami_id), hash|
      hash[platform] ||= []
      hash[platform] << [name, ami_id]
    end
  end

  private

  def check_platform_changed
    return unless self.platform_changed?
    errors.add(:platform, "AMI cant't be updated with a different platform")
  end
end
