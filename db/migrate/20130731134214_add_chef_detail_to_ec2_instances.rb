class AddChefDetailToEc2Instances < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :chef_environment, :string
    add_column :ec2_instances, :run_list, :string
  end
end
