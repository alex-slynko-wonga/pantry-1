class AddStatusInfoToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :booted, :string
    add_column :ec2_instances, :bootstrapped, :string
    add_column :ec2_instances, :joined, :string

    remove_column :ec2_instances, :status
  end
end
