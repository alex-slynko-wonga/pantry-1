collection @costs

attributes :cost, :ec2_instance_id

child :ec2_instance do
  attributes :name, :domain
end