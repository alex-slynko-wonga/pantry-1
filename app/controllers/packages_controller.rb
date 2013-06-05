class PackagesController < ApplicationController
  def create
    Package.create(params.permit(:name, :version, :url))
    render nothing: true
  end
  
  def index
    @packages = Package.all
  end
end
