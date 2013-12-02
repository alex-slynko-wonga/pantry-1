class Wonga::Pantry::JenkinsSlaveDestroyer
  def initialize(jenkins_slave, server_ip, server_port = 80, user = nil, sns = Wonga::Pantry::SNSPublisher.new(CONFIG["aws"]["jenkins_slave_delete_topic_arn"]))
    @sns = sns
    @jenkins_slave = jenkins_slave
    @ec2_instance = @jenkins_slave.ec2_instance
    @server_ip = server_ip
    @server_port = server_port
    @user = user
  end

  def delete
    return unless @user.teams.include?(@ec2_instance.team)
    if Wonga::Pantry::Ec2InstanceState.new(@ec2_instance, @user, { 'event' => "termination" }).change_state
      @sns.publish_message({
        'server_ip'         => @server_ip,
        'server_port'       => @server_port,
        'hostname'          => @ec2_instance.name,
        'domain'            => @ec2_instance.domain,
        'instance_id'       => @ec2_instance.instance_id,
        'id'                => @ec2_instance.id,
        'jenkins_slave_id'  => @jenkins_slave.id,
        'chef_environment'  => @ec2_instance.chef_environment
      })
    end
  end
end
