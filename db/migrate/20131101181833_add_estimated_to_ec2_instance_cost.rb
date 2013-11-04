class AddEstimatedToEc2InstanceCost < ActiveRecord::Migration
  def change
    add_column :ec2_instance_costs, :estimated, :boolean
  end
end
