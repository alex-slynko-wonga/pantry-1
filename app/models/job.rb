class Job < ActiveRecord::Base
  attr_accessible :description, :end_time, :name, :start_time, :status
  has_one :job_log
end
