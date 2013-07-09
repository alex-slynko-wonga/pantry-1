class CreateEc2Instances < ActiveRecord::Migration
  def change
    create_table :ec2_instances do |t|
      t.string :name
      t.string :status
      t.string :instance_id

      t.timestamps
    end
  end
end
