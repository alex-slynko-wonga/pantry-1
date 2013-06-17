class ChefNodesController < ApplicationController
  def search
    if params[:search] && params[:search][:role] && params[:search][:environment]
      unless  params[:search][:role].blank? || params[:search][:environment].blank?
        @nodes = ChefNodeResource.list_nodes(params[:search][:environment], params[:search][:role])
        @nodes ||= ["no items matched serch"]
      end
    end
  end
end
