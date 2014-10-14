class CreateRoles < ActiveRecord::Migration
  def change
    create_table :instance_roles do |t|
      t.string :name, null: false
      t.belongs_to :ami, index: true, null: false
      t.string :security_group_ids
      t.string :chef_role, null: false
      t.string :run_list
      t.string :instance_size, null: false
      t.integer :disk_size, null: false
      t.boolean :enabled, null: false

      t.timestamps
    end
  end
end
