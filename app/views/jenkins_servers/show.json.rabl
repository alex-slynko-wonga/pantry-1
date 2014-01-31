object @jenkins_server

attributes :id

child :ec2_instance do
  attributes :id, :name, :ami, :security_group_ids, :human_status
end
