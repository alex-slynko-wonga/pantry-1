class CreateJenkinsSlaves < ActiveRecord::Migration
  def change
    create_table :jenkins_slaves do |t|
      t.integer :jenkins_server_id
      t.integer :ec2_instance_id

      t.timestamps
    end

    add_index :jenkins_slaves, :jenkins_server_id
    add_index :jenkins_slaves, :ec2_instance_id
  end
end
