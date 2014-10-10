class Wonga::Pantry::Ec2Adapter
  SECURITY_GROUPS_REGEX = /\A#{CONFIG['pantry']['security_groups_prefix']}([a-zA-Z0-9])+-([A-Z0-9]{12,13})\Z/

  def initialize(user)
    @user = user
  end

  def amis
    AmiPolicy::Scope.new(@user, Ami).resolve.group_by_platform
  end

  def flavors
    CONFIG['aws']['ebs']
  end

  def get_ami_attributes(ami)
    return if ami.blank?
    image = ec2.client.describe_images(image_ids: [ami])[:images_set][0]
    return unless image

    image[:platform] ||= 'linux'
    image
  rescue AWS::EC2::Errors::InvalidAMIID::NotFound, AWS::EC2::Errors::InvalidAMIID::Malformed
    {}
  end

  def generate_volumes(ami, main_volume_size, *additional_volume_sizes)
    image = ec2.images[ami]
    all_block_devices = image.block_devices
    block_devices = all_block_devices.reject { |device| device[:virtual_name] && device[:virtual_name]['ephemeral'] }
    volume_sizes = ([main_volume_size] + additional_volume_sizes).reject(&:blank?).map(&:to_i)

    volumes = block_devices.map.with_index do |mapping, i|
      Ec2Volume.new(size: volume_sizes[i]) do |volume|
        volume.device_name = mapping[:device_name]
        volume.snapshot = mapping[:ebs][:snapshot_id]
        volume.size = mapping[:ebs][:volume_size] if volume.size.to_i < mapping[:ebs][:volume_size]
        volume.volume_type ||= mapping[:ebs][:volume_type]
      end
    end

    device_name = image.platform == 'windows' ? 'xvdf' : '/dev/sdf'
    Array(volume_sizes[block_devices.size..-1]).each do |volume_size|
      while volumes.any? { |volume| volume.device_name == device_name } ||
            all_block_devices.any? { |mapping| mapping[:device_name] == device_name }
        device_name = device_name.next
      end
      volumes << Ec2Volume.new(size: volume_size.to_i, device_name: device_name)
    end

    volumes
  end

  def platform_for_ami(ami)
    image = ec2.images[ami]

    return unless image.exists?
    image.platform.presence || 'linux'
  end

  def security_groups
    groups = ec2.client.describe_security_groups(
      filters: [{ name: 'vpc-id',
                  values: [CONFIG['aws']['vpc_id']] }]
    )[:security_group_info].map do |group|
      [group[:group_name], group[:group_id]]
    end.sort

    groups.select! { |(name, _)| name[SECURITY_GROUPS_REGEX] } unless ec2_adapter_policy.show_all_security_groups?
    groups.delete_if { |(_, id)| id == CONFIG['aws']['security_group_linux'] || id == CONFIG['aws']['security_group_windows'] }
  end

  def subnets
    if ec2_adapter_policy.show_all_subnets?
      ec2.subnets
    else
      ec2.subnets.filter('tag:Network', 'Private*')
    end.map { |s| [s.tags['Name'] || s.id, s.id] }
  end

  private

  def ec2
    @ec2 ||= AWS::EC2.new
  end

  def ec2_adapter_policy
    @ec2_adapter = Ec2AdapterPolicy.new(@user)
  end
end
