class AddAmiAndFlavorToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :ami, :string
    add_column :ec2_instances, :flavor, :string
  end
end
