class AddTimesToEc2Instance < ActiveRecord::Migration
  def change
      add_column :ec2_instances, :start_time, :datetime
      add_column :ec2_instances, :end_time, :datetime
  end
end
