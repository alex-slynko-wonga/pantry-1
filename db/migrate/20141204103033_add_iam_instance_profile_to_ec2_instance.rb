class AddIamInstanceProfileToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :iam_instance_profile, :string
  end
end
