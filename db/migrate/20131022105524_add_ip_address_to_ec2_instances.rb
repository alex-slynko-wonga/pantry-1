class AddIpAddressToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :ip_address, :string
  end
end
