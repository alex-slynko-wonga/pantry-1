object @ec2_instance

attributes :id, :instance_id, :name, :ip_address, :human_status

node(:policies) { |instance| policy(instance) }
