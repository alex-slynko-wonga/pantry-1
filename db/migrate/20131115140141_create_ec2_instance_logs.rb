class CreateEc2InstanceLogs < ActiveRecord::Migration
  def change
    create_table :ec2_instance_logs do |t|
      t.integer :ec2_instance_id
      t.string :from_state
      t.string :event
      t.integer :user_id

      t.timestamps
    end
  end
end
