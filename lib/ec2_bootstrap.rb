Ec2Bootstrap = Struct.new(:instance_id) do
  def perform
    ec2_instance = AWSResource.new.find_server_by_id instance_id
    windows = ec2_instance.platform == "windows"
    machine_address = ec2_instance.private_dns_name || ec2_instance.private_ip_address

    runner = windows ? WinRMRunner.new : SshRunner.new
    runner.add_host machine_address
    runner.run_commands "chef-client"
  end
end

