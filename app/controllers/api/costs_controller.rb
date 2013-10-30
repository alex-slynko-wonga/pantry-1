class Api::CostsController < ApiController
  def create
    ec2_instance_cost = Ec2InstanceCost.create(ec2_instance_cost_attributes)
    respond_with({:msg => "success"}, :location => ec2_instance_costs_url)
  end
  
private

  def ec2_instance_cost_attributes
    params.require(:ec2_instance_cost).permit(:bill_date, :cost, :ec2_instance_id)
  end
end
