class PackagesController < ApplicationController
  def create
    Package.create(params.permit(:name, :version, :url, :bag_title, :item_title))
    render nothing: true
  end

  def index
    @packages = Package.includes(:job).all
  end

  def deploy
    job = Job.where(package_id: params[:id]).first_or_create
    redirect_to job
  end
end
