class CreateAdminMaintenanceWindows < ActiveRecord::Migration
  def change
    create_table :admin_maintenance_windows do |t|
      t.string :name
      t.text :description
      t.string :message
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :enabled
      t.references :user

      t.timestamps
    end
  end
end
