class Wonga::Pantry::AWSUtility
  def initialize(sqs = Wonga::Pantry::SQSSender.new )
    @sqs = sqs
  end

  def jenkins_instance_params
    {
      ami:                "ami-00110010",
      security_group_ids: "sg-00110012",
      run_list:           "role[linux_jenkins_server]",          
      platform:           "linux",
      flavor:             "t1.micro",
      chef_environment:   "pantry"         
    }
  end

  def request_jenkins_instance(additional_params, jenkins_instance)
    instance_params = jenkins_instance_params.merge(additional_params)
    ec2_instance = Ec2Instance.new(instance_params)
    Ec2Instance.transaction do 
      ec2_instance.save!
      jenkins_instance.ec2_instance = ec2_instance
      jenkins_instance.save!
    end
    msg = ec2_instance.boot_message

    if jenkins_instance.persisted?
      @sqs.send_message(msg)
    end
  end
end
