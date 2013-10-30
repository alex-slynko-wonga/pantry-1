class CreateEc2InstanceCosts < ActiveRecord::Migration
  def change
    create_table :ec2_instance_costs do |t|
      t.date :bill_date
      t.decimal :cost, precision: 10, scale: 2
      t.references :ec2_instance

      t.timestamps
    end

    add_index :ec2_instance_costs, [:bill_date, :ec2_instance_id]
  end
end
