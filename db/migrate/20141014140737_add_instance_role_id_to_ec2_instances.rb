class AddInstanceRoleIdToEc2Instances < ActiveRecord::Migration
  def change
    add_reference :ec2_instances, :instance_role, index: true
  end
end
