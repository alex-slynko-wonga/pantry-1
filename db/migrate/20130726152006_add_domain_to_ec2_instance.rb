class AddDomainToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :domain, :string
  end
end
