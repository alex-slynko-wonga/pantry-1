class Wonga::Pantry::JenkinsSlaveDestroyer
  def initialize(ec2_instance, server_ip, server_port = 80, user = nil, sqs = Wonga::Pantry::SQSSender.new(CONFIG["aws"]["jenkins_slave_delete_queue_name"]))
    @sqs = sqs
    @ec2_instance = ec2_instance
    @ec2_instance.update_attributes(terminated_by: user)
    @server_ip = server_ip
    @server_port = server_port
  end
  
  def delete
    @sqs.send_message({
      'server_ip' => @server_ip, 'server_port' => @server_port,
      'node' => @ec2_instance.name, 'instance_id' => @ec2_instance.instance_id, 'id' => @ec2_instance.id
    })
  end
end
