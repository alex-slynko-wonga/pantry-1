class AddVolumeSizeToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :volume_size, :integer
  end
end
