class Ec2Instance < ActiveRecord::Base  
  belongs_to :team
  belongs_to :user

  validates :name, presence: true
  validates :team_id, presence: true 
  validates :user_id, presence: true

  before_validation :init, on: :create
  before_create :set_start_time

  def exists!(instance_id)
    self.instance_id
  end

  def complete!(status)
    case status 
    when :booted
      self.booted = true
    when :bootstrapped
      self.bootstrapped = true
    when :joined
      self.joined = true
      self.end_time = Time.current
    end
  end

  def get_status
    {
      booted: self.booted,
      bootstrapped: self.bootstrapped,
      joined: self.joined
    }
  end

  def human_status
    return "Ready" if bootstrapped && joined
    if bootstrapped
      "Bootstrapped"
    elsif joined
      "Joined to domain"
    elsif booted
      "Booted"
    else
      "Booting"
    end
  end

  private
    def init
      self.booted ||= false
      self.bootstrapped ||= false
      self.joined ||= false
      self.instance_id = 'pending'
    end

    def set_start_time
      self.start_time = Time.current
    end
end
