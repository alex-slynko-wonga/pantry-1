class TotalCostsController < ApplicationController
  respond_to :json

  def show
    respond_with TotalCost.where(bill_date: params[:id].to_date).first
  end
end
