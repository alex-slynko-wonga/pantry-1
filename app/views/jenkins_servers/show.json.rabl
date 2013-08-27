object @jenkins_server

attributes :id

child :ec2_instance do
  attributes :id, :name, :ami, :security_group_ids, :bootstrapped, :booted, :joined 
end