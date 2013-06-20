class JobsController < ApplicationController
  def create
    job = Job.create(params.permit(:name, :description, :status))
    render text: job_url(job), status: 201
  end
  
  def update
    job = Job.find(params[:id])
    job.status = params[:status]
    job.save
    render nothing: true
  end
  
  def show
    @job = Job.find(params[:id])
    
  end

  def index
    @jobs = Job.all
  end
end
