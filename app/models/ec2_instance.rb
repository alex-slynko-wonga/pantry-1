class Ec2Instance < ActiveRecord::Base
  attr_accessible :instance_id, :name, :status

  has_many :job_log

  before_validation do 
  	self.status ||= 'pending'
  end

  after_create do 
  end

  def start!
  	self.status = 'started'
  	self.start_time = Time.current
  	self.save!
  end

  def complete!
  	self.status = 'completed'
  	self.end_time = Time.current
  	self.save!
  end

  def job_status
  	case status
  	when 'started'
  		"Started at #{start_time}"
  	when 'completed'
  		"Completed at #{end_time}"
  	else
  		"In progress since #{start_time}"
  	end
  end
end
