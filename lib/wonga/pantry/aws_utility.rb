class Wonga::Pantry::AWSUtility
  def initialize(sqs = Wonga::Pantry::SQSSender.new )
    @sqs = sqs
  end

  def jenkins_instance_params(jenkins_instance)
    params = {
      ami:                "ami-00110010",
      security_group_ids: "sg-00110012",
      platform:           "linux",
      chef_environment:   jenkins_instance.team.chef_environment,
      name:               jenkins_instance.instance_name,
      flavor:             "t1.micro"
    }

    if jenkins_instance.instance_of?(JenkinsServer)
      params.merge(run_list: "role[jenkins_linux_server]")
    else
      params.merge(run_list: "role[jenkins_windows_agent]")
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
