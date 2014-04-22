class Admin::MaintenanceWindow < ActiveRecord::Base
  belongs_to :user

  before_validation :window_start_on_enable
  before_validation :window_stop_on_disable

  validate :window_single_active
  validates :name, presence: true
  validates :description, presence: true
  validates :message, presence: true
  validates :user, presence: true
  validate :window_re_enable

  scope :active, -> { where(enabled: true) }

  private
  def window_start_on_enable
    if start_at.blank? && end_at.blank? && enabled?
      self.start_at = Time.current
    end
  end

  def window_stop_on_disable
    if start_at.present? && end_at.blank? && !enabled?
      self.end_at = Time.current
    end
  end

  def window_re_enable
    if start_at.present? && end_at.present? && enabled?
      errors.add(:name, "Can not re-enable a completed Maintenance Window. Please create a new one.")
    end
  end

  def window_single_active
    return unless enabled

    if active_window = Admin::MaintenanceWindow.active.where.not(id: id).first
      errors.add(:name, "Only one active Maintenance Window allowed. #{active_window.name} is enabled.")
    end
  end
end
