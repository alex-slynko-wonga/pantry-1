class Ec2InstanceCostsController < ApplicationController
  def index
    @costs = costs.costs_per_team

    respond_to do |format|
      format.json do
        @costs.map! { |cost| OpenStruct.new(cost) }
      end

      format.html do
        @bill_date = costs.bill_date
        @available_dates = Ec2InstanceCost.get_available_dates.map {|date| [date.strftime("%d-%m-%Y"), date.strftime("%B %Y")]}
      end
    end
  end

  private
  def costs
    @pantry_costs ||= Wonga::Pantry::Costs.new(params[:date]) #unless params[:date].blank?
  end
end
