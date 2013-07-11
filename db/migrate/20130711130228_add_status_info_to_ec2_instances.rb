class AddStatusInfoToEc2Instances < ActiveRecord::Migration
  def change
      add_column :ec2_instances, :booted, :boolean
      add_column :ec2_instances, :bootstrapped, :boolean
      add_column :ec2_instances, :joined, :boolean

      remove_column :ec2_instances, :status
  end
end
