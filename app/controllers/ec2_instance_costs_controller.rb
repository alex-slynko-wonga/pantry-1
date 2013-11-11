class Ec2InstanceCostsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @costs = costs.costs_per_team.map { |cost| OpenStruct.new(cost) }
      end

      format.html do
        @available_dates = Ec2InstanceCost.get_available_dates.map {|date| [date.strftime("%d-%m-%Y"), date.strftime("%B %Y")]}
      end
    end
  end

  private
  def costs
    @pantry_costs ||= Wonga::Pantry::Costs.new(params[:date])
  end
end
