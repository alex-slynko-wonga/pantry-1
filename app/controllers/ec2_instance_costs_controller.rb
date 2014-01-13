class Ec2InstanceCostsController < ApplicationController
  def index
    authorize(Ec2InstanceCost)
    respond_to do |format|
      format.json do
        @costs = costs.costs_per_team
      end

      format.html do
        @available_dates = Ec2InstanceCost.get_available_dates.map {|date| [date.strftime("%d-%m-%Y"), date.strftime("%B %Y")]}
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @costs = costs.costs_details_per_team(params[:id])
      end
    end
  end

  private
  def costs
    @pantry_costs ||= Wonga::Pantry::Costs.new(params[:date])
  end
end
