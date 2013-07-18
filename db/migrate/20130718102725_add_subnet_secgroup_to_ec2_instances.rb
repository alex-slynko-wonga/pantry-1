class AddSubnetSecgroupToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :subnet_id, :string
    add_column :ec2_instances, :security_group_ids, :string
  end
end
