class Wonga::Pantry::JenkinsUtility
  def request_jenkins_instance(additional_params, jenkins_instance)
    role = InstanceRole.for(jenkins_instance).find(additional_params[:instance_role_id])
    instance_params = additional_params.merge(role.instance_attributes.merge(name: jenkins_instance.instance_name))

    ec2_instance = jenkins_instance.ec2_instance = Ec2Instance.new(instance_params)
    ec2_instance.environment = ec2_instance.team.ci_environment
    ec2_resource = Wonga::Pantry::Ec2Resource.new(ec2_instance, ec2_instance.user)
    ec2_resource.boot
  end
end
