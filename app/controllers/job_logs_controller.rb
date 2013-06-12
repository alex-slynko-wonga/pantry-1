class JobLogsController < ApplicationController
  def create
    @job_log = JobLog.create(params.permit(:job_id, :log_text))
    render text: job_log_url(@job_log), status: 201
  end

  def update
    @job_log = JobLog.find(params[:id])
    @job_log.log_text = @job_log.log_text + params[:log_text]
    @job_log.save
    render text: job_log_url(@job_log), status: 200
  end

  def show
    @job_log = JobLog.find(params[:id])
  end

  def index
    @job_logs = JobLog.all
  end
end
