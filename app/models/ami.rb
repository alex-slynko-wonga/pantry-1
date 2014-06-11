class Ami < ActiveRecord::Base
  PLATFORM = %w( windows linux )

  validates :ami_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :platform, inclusion: PLATFORM, presence: true

  scope :visible, -> { where(hidden: [false, nil]) }

  def self.group_by_platform
    order(:name).pluck(:platform, :name, :ami_id).each_with_object({}) do |(platform, name, ami_id), hash|
      hash[platform] ||= []
      hash[platform] << [name, ami_id]
    end
  end
end
