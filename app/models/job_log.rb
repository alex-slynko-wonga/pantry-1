class JobLog < ActiveRecord::Base
  attr_accessible :job_id, :log_text
  belongs_to :job, :ec2_instance
end
