class Schedule < ActiveRecord::Base
  belongs_to :team

  validates :team, presence: true
  validates :start_time, presence: true
  validates :shutdown_time, presence: true

  scope :daily, -> { where(weekend_only: false) }
end
