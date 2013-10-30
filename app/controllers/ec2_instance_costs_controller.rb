class Ec2InstanceCostsController < ApplicationController
  def index
    @costs = costs.costs_per_team
    @bill_date = costs.bill_date
  end

  private
  def costs
    @pantry_costs ||= Wonga::Pantry::Costs.new(params[:date])
  end
end
