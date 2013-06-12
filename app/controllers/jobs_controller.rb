class JobsController < ApplicationController
  def create
    Job.create(params.permit(:name, :description))
    render nothing: true
  end

  def index
    @jobs = Job.all
  end
end
