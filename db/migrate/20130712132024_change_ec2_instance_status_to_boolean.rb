class ChangeEc2InstanceStatusToBoolean < ActiveRecord::Migration
  remove_column :ec2_instances, :booted
  remove_column :ec2_instances, :bootstrapped
  remove_column :ec2_instances, :joined

  add_column :ec2_instances, :booted, :boolean
  add_column :ec2_instances, :bootstrapped, :boolean
  add_column :ec2_instances, :joined, :boolean
end
