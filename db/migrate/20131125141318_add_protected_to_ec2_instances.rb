class AddProtectedToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :protected, :boolean
  end
end
