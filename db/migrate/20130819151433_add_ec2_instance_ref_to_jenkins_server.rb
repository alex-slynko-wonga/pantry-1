class AddEc2InstanceRefToJenkinsServer < ActiveRecord::Migration
  def change
    add_column :jenkins_servers, :ec2_instance_id, :integer
  end
end
