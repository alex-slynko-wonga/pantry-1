class Wonga::Pantry::BootMessage
  def boot_message(instance)
    fail unless instance.persisted?
    message = {
      pantry_request_id:          instance.id,
      instance_name:              instance.name,
      domain:                     instance.domain,
      flavor:                     instance.flavor,
      ami:                        instance.ami,
      team_id:                    instance.team_id,
      team_name:                  instance.team.name,
      user_id:                    instance.user_id,
      subnet_id:                  instance.subnet_id,
      security_group_ids:         security_group_ids(instance),
      chef_environment:           instance.environment.chef_environment,
      run_list:                   instance.run_list.split(/\r\n|,/),
      aws_key_pair_name:          CONFIG['aws']['key_pair_name'],
      platform:                   instance.platform,
      http_proxy:                 CONFIG['aws']['http_proxy'],
      windows_set_admin_password: true,
      windows_admin_password:     CONFIG['aws']['windows_admin_password'],
      ou:                         Wonga::Pantry::ActiveDirectoryOU.new(instance).ou,
      block_device_mappings:      block_device_mappings(instance),
      protected:                  instance.protected?
    }

    bootstrap_username = bootstrap_message(instance.ami)
    message = message.merge(bootstrap_username: bootstrap_username) unless bootstrap_username.nil? || bootstrap_username.empty?
    message = message.merge(iam_instance_profile: instance.iam_instance_profile) if instance.iam_instance_profile
    message
  end

  private

  def bootstrap_message(ami_id)
    amis = Ami.where(ami_id: ami_id)
    bootstrap_username = amis.first.bootstrap_username if amis.any?
    bootstrap_username
  end

  def security_group_ids(instance)
    security_groups = Array(instance.security_group_ids)
    security_groups.uniq
  end

  def block_device_mappings(instance)
    instance.ec2_volumes.map do |volume|
      {
        device_name: volume.device_name,
        ebs: {
          volume_size: volume.size,
          snapshot_id: volume.snapshot,
          volume_type: volume.volume_type,
          delete_on_termination: true
        }
      }
    end
  end
end
