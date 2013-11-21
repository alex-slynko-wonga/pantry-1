class AddDnsToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :dns, :boolean
  end
end
