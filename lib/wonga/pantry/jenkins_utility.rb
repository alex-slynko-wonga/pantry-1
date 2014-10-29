class Wonga::Pantry::JenkinsUtility
  def jenkins_instance_params(jenkins_instance)
    params = {
      name:               jenkins_instance.instance_name
    }
    security_groups = Array(params['security_group_ids'])
    security_groups << CONFIG['aws']['security_group_jenkins']
    params['security_group_ids'] = security_groups.uniq

    if jenkins_instance.instance_of?(JenkinsServer)
      params.merge(
        ami: CONFIG['aws']['jenkins_linux_ami'],
        run_list: CONFIG['aws']['jenkins_linux_server_role'],
        flavor: CONFIG['aws']['jenkins_server_flavor'],
        platform: 'linux',
        protected: true
      )
    else
      params.merge(
        ami: CONFIG['aws']['jenkins_windows_ami'],
        run_list: CONFIG['aws']['jenkins_windows_agent_role'],
        flavor: CONFIG['aws']['jenkins_windows_agent_flavor'],
        platform: 'windows'
      )
    end
  end

  def request_jenkins_instance(additional_params, jenkins_instance)
    instance_params = jenkins_instance_params(jenkins_instance).merge(additional_params)
    ec2_instance = jenkins_instance.ec2_instance = Ec2Instance.new(instance_params)
    ec2_instance.environment = ec2_instance.team.ci_environment
    ec2_resource = Wonga::Pantry::Ec2Resource.new(ec2_instance, ec2_instance.user)
    ec2_resource.boot
  end
end
