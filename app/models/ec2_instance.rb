class Ec2Instance < ActiveRecord::Base
  #attr_accessible :instance_id, :name, :status
  #attr_accessible :start_time, :end_time, :team_id
  #instance_id returned from fog, name from form

  has_many :job_logs

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
