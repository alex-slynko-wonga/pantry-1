class Wonga::Pantry::BootMessage
  def initialize(instance)
    @instance = instance
  end

  def boot_message
    {
      pantry_request_id:          @instance.id,
      instance_name:              @instance.name,
      domain:                     @instance.domain,
      flavor:                     @instance.flavor,
      ami:                        @instance.ami,
      team_id:                    @instance.team_id,
      subnet_id:                  @instance.subnet_id,
      security_group_ids:         security_group_ids,
      chef_environment:           @instance.chef_environment,
      run_list:                   @instance.run_list.split("\r\n"),
      aws_key_pair_name:          "aws-ssh-keypair",
      platform:                   @instance.platform,
      http_proxy:                 "http://proxy.example.com:8080",
      windows_set_admin_password: true,
      windows_admin_password:     "LocalAdminPassword",
      ou: Wonga::Pantry::ActiveDirectoryOU.new(@instance).ou
    }
  end

  private
  def security_group_ids
    security_groups = Array(@instance.security_group_ids)
    if @instance.platform == 'windows'
      security_groups << 'sg-00110011'
    else
      security_groups << 'sg-00110010'
    end
    security_groups.uniq
  end
end

