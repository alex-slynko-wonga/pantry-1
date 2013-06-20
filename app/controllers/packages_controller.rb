class PackagesController < ApplicationController
  def create
    Package.create(params.permit(:name, :version, :url, :bag_title, :item_title))
    render nothing: true
  end

  def index
    @packages = Package.all
  end
end
