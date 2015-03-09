class CreateInstanceSchedules < ActiveRecord::Migration
  def change
    create_table :instance_schedules do |t|
      t.belongs_to :ec2_instance, null: false
      t.belongs_to :schedule, null: false
    end
    add_foreign_key :instance_schedules, :ec2_instances
    add_foreign_key :instance_schedules, :schedules
    add_index :instance_schedules, [:ec2_instance_id, :schedule_id], unique: true
  end
end
