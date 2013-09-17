class Wonga::Pantry::AWSUtility
  def initialize(sqs = Wonga::Pantry::SQSSender.new )
    @sqs = sqs
  end

  def jenkins_instance_params(jenkins_instance)
    params = {
      security_group_ids: CONFIG["aws"]["security_group_jenkins"],
      flavor:             CONFIG["aws"]["jenkins_flavor"],
      chef_environment:   jenkins_instance.team.chef_environment,
      name: jenkins_instance.instance_name
    }

    if jenkins_instance.instance_of?(JenkinsServer)
      params.merge(
        ami: CONFIG["aws"]["jenkins_linux_ami"],
        run_list: CONFIG["aws"]["jenkins_linux_server_role"],
        platform: 'linux'
      )
    else
      params.merge(
        ami: CONFIG["aws"]["jenkins_windows_ami"],
        run_list: CONFIG["aws"]["jenkins_windows_agent_role"],
        platform: 'windows'
      )
    end
  end

  def request_jenkins_instance(additional_params, jenkins_instance)
    instance_params = jenkins_instance_params(jenkins_instance).merge(additional_params)
    jenkins_instance.ec2_instance = Ec2Instance.new(instance_params)
    if jenkins_instance.save
      message = Wonga::Pantry::BootMessage.new(jenkins_instance.ec2_instance)
      @sqs.send_message(message)
      true
    end
  end 
end
