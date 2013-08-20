module Wonga
	class AWSUtility
		def initialize(sqs = AWS::SQS::Client.new)
			@sqs = sqs
		end

		def default_instance_params()
	    instance_params = {
	      domain:             "example.com",
	      subnet_id:          "subnet-a8dc0bc0",
	      name: 							"pending",
	      instance_id: 				"pending"
	    }	
	  end

	  def jenkins_instance_params()
	  	default_instance_params.merge(
	  	  {
		      ami:                "ami-00110010",
					security_group_ids: "sg-2ee73959",
					#[
					#	"sg-2ee73959", 		#base-linux
					#	"sg-00110012", 		#ukrc2-jenkins-server
					#],
					run_list: 					"role[linux_jenkins_server]",          
		      platform:           "linux",
		      flavor:  						"t1.micro",
		      chef_environment: 	"pantry"         
	      }
	    )
	  end

		def request_instance(additional_params)
			instance_params = default_instance_params().merge(additional_params)
	    ec2_instance = Ec2Instance.new(instance_params)
      msg = ec2_instance.boot_message
      msg['http_proxy'] = "http://proxy.example.com:8080"
      msg['windows_set_admin_password'] = true
      msg['windows_admin_password'] = "LocalAdminPassword"
      queue_url = @sqs.get_queue_url(queue_name: "pantry_wonga_aws-ec2_boot_command")[:queue_url]
      puts "QUEUE #{queue_url}"
      @sqs.send_message(queue_url: queue_url, message_body: msg.to_json )
	    return ec2_instance
	  end

	  def request_jenkins_server(additional_params)
	  	if !JenkinsServer.find_by_team_id(additional_params[:team_id]).nil?
	  		return false
	  	end
	    instance_params = jenkins_instance_params().merge(additional_params)
	    ec2_instance = request_instance(instance_params)
  		jenkins_server = JenkinsServer.new(
  			ec2_instance_id: ec2_instance.id,
  			team_id: additional_params[:team_id]
  		)
	  	return jenkins_server
	  end
	end
end

