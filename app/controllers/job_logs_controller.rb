class JobLogsController < ApplicationController
  def create
    JobLog.create(params.permit(:job_id, :log_text))
    render nothing: true
  end

  def index
    @job_logs = JobLog.all
  end
end
