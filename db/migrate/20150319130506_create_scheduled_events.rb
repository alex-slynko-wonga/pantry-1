class CreateScheduledEvents < ActiveRecord::Migration
  def change
    create_table :scheduled_events do |t|
      t.belongs_to :ec2_instance, index: true
      t.datetime :event_time
      t.string :event_type

      t.timestamps null: false
    end
    add_foreign_key :scheduled_events, :ec2_instances
    add_index :scheduled_events, [:event_type, :event_time]
  end
end
