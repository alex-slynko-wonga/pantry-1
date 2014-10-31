class Wonga::Pantry::JenkinsSlaveDestroyer
  def initialize(jenkins_slave,
                 server_fqdn,
                 server_port = 80,
                 user = nil,
                 sns = Wonga::Pantry::SNSPublisher.new(CONFIG['aws']['jenkins_slave_delete_topic_arn']))
    @sns = sns
    @jenkins_slave = jenkins_slave
    @ec2_instance = @jenkins_slave.ec2_instance
    @server_fqdn = server_fqdn
    @server_port = server_port
    @user = user
  end

  def delete
    @sns.publish_message('server_fqdn'       => @server_fqdn,
                         'server_port'       => @server_port,
                         'hostname'          => @ec2_instance.name,
                         'domain'            => @ec2_instance.domain,
                         'instance_id'       => @ec2_instance.instance_id,
                         'id'                => @ec2_instance.id,
                         'jenkins_slave_id'  => @jenkins_slave.id,
                         'chef_environment'  => @ec2_instance.environment.chef_environment,
                         'user_id'           => @user.id)
  end
end
