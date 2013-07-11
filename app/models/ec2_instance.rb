class Ec2Instance < ActiveRecord::Base  
  before_save :init!
  has_many :job_logs

  def init!
    self.start_time = Time.current
    self.booted = 'pending'
    self.bootstrapped = 'pending'
    self.joined = 'pending'
    self.instance_id = 'pending'
  end

  def start!(status, *instance_id)
    case status 
    when :booted
      self.booted = 'started'
      self.instance_id = instance_id
    when :bootstrapped
      self.bootstrapped = 'started'
    when :joined
      self.joined = 'started'
    end
  end

  def complete!(status)
    case status 
    when :booted
      self.booted = 'completed'
    when :bootstrapped
      self.bootstrapped = 'completed'
    when :joined
      self.joined = 'completed'
      self.end_time = Time.current
    end
  end

  def get_status
    return {
      booted: self.booted,
      bootstrapped: self.bootstrapped,
      joined: self.joined
    }
  end
end
