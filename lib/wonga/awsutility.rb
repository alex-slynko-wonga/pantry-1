class AWSUtility
	def initialize(sqs = AWS::SQS::Client.new)
		@sqs = sqs
	end

	def default_instance_params()
    instance_params = {
      domain:             "example.com",
      subnet_id:          "subnet-a8dc0bc0",
      aws_key_pair_name:  "aws-ssh-keypair",
    }	
  end

  def jenkins_instance_params()
  	default_instance_params().merge
  	(
    	{
	      ami:                "ami-00110010",
				security_group_ids: [
					"sg-2ee73959", 		#base-linux
					"sg-00110012", 		#ukrc2-jenkins-server
				],
				run_list: 					["role[linux_jenkins_server]"],          
	      platform:           "linux"          
    	}
    )
  end

	def request_instance(additional_params)
		instance_params = default_instance_params().merge(additional_params)
    ec2_instance = Ec2Instance.new(instance_params)
    if ec2_instance.save
      msg = ec2_instance.boot_message
      msg['http_proxy'] = "http://proxy.example.com:8080"
      msg['windows_set_admin_password'] = true
      msg['windows_admin_password'] = "LocalAdminPassword"
      queue_url = sqs.get_queue_url(queue_name: "pantry_wonga_aws-ec2_boot_command")[:queue_url]
      puts "QUEUE #{queue_url}"
      @sqs.send_message(queue_url: queue_url, message_body: msg.to_json )
      return ec2_instance
    else
    	return false
    end
  end

	#additional_params: name, team, flavor, run_list, user_id
  def create_jenkins_server(additional_params)
    instance_params = jenkins_instance_params().merge(additional_params)
    ec2_instance = request_instance(instance_params)
  	if ec2_instance
  		jenkins_server = JenkinsServer.new(
  			team_id: team,
  			ec2_instance_id = ec2_instance.id
  		)
  		return jenkins_server
  	else
  		return false
  	end
  end
end


