class AddUserToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :user_id, :integer
  end
end
