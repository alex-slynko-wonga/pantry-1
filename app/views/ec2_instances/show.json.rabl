object @ec2_instance

attributes :id, :instance_id, :name, :ip_address, :human_status, :flavor

node(:policies) { |instance| policy(instance).as_json }
