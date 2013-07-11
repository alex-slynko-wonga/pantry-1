class Ec2Instance < ActiveRecord::Base
  #attr_accessible :instance_id, :name, :status
  #attr_accessible :start_time, :end_time, :team_id
  #instance_id returned from fog, name from form
  after_create :init
  has_many :job_logs

  def init
    self.start_time = Time.current
    self.booted = 'pending'
    self.bootstrapped = 'pending'
    self.joined = 'pending'
    self.instance_id = 'pending'
  end

  def start!(status)
    case status 
    when :booted
      self.booted = 'started'
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
end
