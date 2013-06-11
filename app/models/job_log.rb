class JobLog < ActiveRecord::Base
  attr_accessible :job_id, :log_text
end
