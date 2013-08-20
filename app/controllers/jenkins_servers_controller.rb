class JenkinsServersController < ApplicationController
  def new
	@user_teams = current_user.teams
	@jenkins_server = JenkinsServer.new
  end

  def create
	@jenkins_server = JenkinsServer.new(jenkins_attributes)

	if @jenkins_server.save
		send_create_server_command
		redirect_to @jenkins_server
	else
		render :new
	end
  end

  def show
    @jenkins_server = JenkinsServer.find(params[:id])
  end

  private 
  
  def jenkins_attributes
	params.require(:jenkins_server).permit(:team_id)
  end

  def send_create_server_command
	sqs = AWS::SQS.new
	url = sqs.queues.url_for("pantry_wonga_aws-ec2_boot_command")
	sqs.queues[url].send_message(message)
  end

  def message
	{
		pantry_request_id: @jenkins_server.id,
		instance_name: "#{@jenkins_server.team.id}",
		domain: "example.com",
		flavour: "m1.medium",
		ami: "ami-00110010", #Canonical Ubuntu 12.4 64-bit paravirtual
		team_id: @jenkins_server.team.id,
		subnet_id: "subnet-a8dc0bc0",
		security_group_ids: ["sg-2ee73959", #base-linux
							 "sg-00110012", #ukrc2-jenkins-server
							],
		chef_environment: @jenkins_server.team.name.underscore,
		run_list: ["role[linux_jenkins_server]"],
		aws_key_pair_name: "aws-ssh-keypair"
	}.to_json
  end

end
