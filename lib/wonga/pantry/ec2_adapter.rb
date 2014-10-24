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
    return unless image = ec2.client.describe_images(image_ids: [ami])[:images_set][0]
    image[:platform] ||= 'linux'
    image
  rescue AWS::EC2::Errors::InvalidAMIID::NotFound, AWS::EC2::Errors::InvalidAMIID::Malformed
    {}
  end

  def platform_for_ami(ami)
    image = ec2.images[ami]

    return unless image.exists?
    image.platform.presence || 'linux'
  end

  def security_groups
    groups = ec2.client.describe_security_groups(
      :filters => [ { :name =>"vpc-id",
                      :values => [CONFIG['aws']['vpc_id']] } ]
    )[:security_group_info].map do |group|
      [ group[:group_name], group[:group_id] ]
    end.sort

    groups.select! {|(name, _)| name[SECURITY_GROUPS_REGEX] } unless ec2_adapter_policy.show_all_security_groups?
    groups.delete_if {|(_, id)| id == CONFIG['aws']['security_group_linux'] || id == CONFIG['aws']['security_group_windows']}
  end

  def subnets
    if ec2_adapter_policy.show_all_subnets?
      ec2.subnets
    else
      ec2.subnets.filter("tag:Network", "Private*")
    end.map{|s| [s.tags["Name"] || s.id, s.id]}
  end

  def ec2
    @ec2 ||= AWS::EC2.new
  end

  private

  def ec2_adapter_policy
    Ec2AdapterPolicy.new(@user)
  end
end

