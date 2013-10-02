class AddTerminatedToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :terminated, :boolean
    add_column :ec2_instances, :terminated_by_id, :integer
  end
end
