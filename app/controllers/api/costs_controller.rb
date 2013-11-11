class Api::CostsController < ApiController
  def create
    bill_date = params[:bill_date].to_date
    params[:ec2_total].each do |entry|
      cost = Ec2InstanceCost.where(ec2_instance_id: entry[:instance_id], bill_date: bill_date).first_or_initialize
      cost.update_attributes(cost: entry[:cost], estimated: entry[:estimated])
    end
    TotalCost.where(bill_date: bill_date).first_or_initialize.update_attributes(cost: params[:total_cost])

    respond_with({:msg => "success"}, :location => ec2_instance_costs_url)
  end
end
