class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.time :start_time, null: false
      t.time :shutdown_time, null: false
      t.belongs_to :team, index: true, null: false
      t.boolean :weekend_only, null: false, default: false

      t.timestamps null: false
    end
    add_foreign_key :schedules, :teams
    add_index :schedules, [:weekend_only, :start_time]
    add_index :schedules, [:weekend_only, :shutdown_time]
  end
end
