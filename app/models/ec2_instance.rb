class Ec2Instance < ActiveRecord::Base  
  validates :name, presence: true
  validates :team_id, presence: true 
  validates :user_id, presence: true
  attr_accessible :instance_id, :name, :team_id, :ami, :flavor, :user_id
  before_save :init!

  def init!
    self.start_time = Time.current
    self.booted ||= false
    self.bootstrapped ||= false
    self.joined ||= false
    self.instance_id ||= 'pending'
  end

  def exists!(instance_id)
    self.instance_id = instance_id
    self.save!
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
    self.save!
  end

  def get_status
    {
      booted: self.booted,
      bootstrapped: self.bootstrapped,
      joined: self.joined
    }
  end
end
