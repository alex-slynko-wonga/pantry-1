class AddUpdatesToEc2InstanceLogs < ActiveRecord::Migration
  def change
    add_column :ec2_instance_logs, :updates, :text
  end
end
