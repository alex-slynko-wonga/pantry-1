class AddPlatformToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :platform, :string
  end
end
