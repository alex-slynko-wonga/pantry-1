class CreateEc2Volumes < ActiveRecord::Migration
  def change
    create_table :ec2_volumes do |t|
      t.belongs_to :ec2_instance, index: true
      t.belongs_to :instance_role, index: true
      t.integer :size, null: false
      t.string :snapshot, limit: 13
      t.string :volume_type, limit: 8, default: 'standard', null: false
      t.string :device_name, limit: 10, null: false

      t.timestamps
    end
  end
end
