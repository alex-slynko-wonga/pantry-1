class RemoveFieldsFromEc2Instance < ActiveRecord::Migration
  def change
    remove_column :ec2_instances, :booted
    remove_column :ec2_instances, :start_time
    remove_column :ec2_instances, :end_time
    remove_column :ec2_instances, :chef_environment
    remove_column :ec2_instances, :terminated_by_id
  end
end
