class AddStateToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :state, :string
  end
end
