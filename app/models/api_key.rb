class ApiKey < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :key, presence: true, uniqueness: true
  validates :permissions, presence: true
  serialize :permissions

  before_validation :check_permissions
  after_initialize :init

  private

  def init
    return if key
    loop do
      self.key = SecureRandom.uuid
      break unless self.class.exists?(key: key)
    end
  end

  def check_permissions
    self.permissions = permissions.uniq.reject(&:empty?) if permissions
  end
end
