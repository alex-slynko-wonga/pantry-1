class Wonga::Pantry::BootMessage
  def initialize(instance)
    @instance = instance
  end

  def boot_message
    raise unless @instance.persisted?
    {
      pantry_request_id:          @instance.id,
      instance_name:              @instance.name,
      domain:                     @instance.domain,
      flavor:                     @instance.flavor,
      ami:                        @instance.ami,
      team_id:                    @instance.team_id,
      user_id:                    @instance.user_id,
      subnet_id:                  @instance.subnet_id,
      security_group_ids:         security_group_ids,
      chef_environment:           @instance.environment.chef_environment,
      run_list:                   @instance.run_list.split(/\r\n|,/),
      aws_key_pair_name:          CONFIG["aws"]["key_pair_name"],
      platform:                   @instance.platform,
      http_proxy:                 CONFIG["aws"]["http_proxy"],
      windows_set_admin_password: true,
      windows_admin_password:     CONFIG["aws"]["windows_admin_password"],
      ou:                         Wonga::Pantry::ActiveDirectoryOU.new(@instance).ou,
      block_device_mappings:      block_device_mappings,
      protected:                  @instance.protected?
    }
  end

  private
  def security_group_ids
    security_groups = Array(@instance.security_group_ids)
    security_groups.uniq
  end

  def block_device_mappings
    [
      {
        device_name: "/dev/sda1",
        ebs: {
          volume_size: @instance.volume_size,
          delete_on_termination: true
        }
      }
    ]
  end
end

