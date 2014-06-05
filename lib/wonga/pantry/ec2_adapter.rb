class Wonga::Pantry::Ec2Adapter
  attr_reader :ec2
  SECURITY_GROUPS_REGEX = /\A#{CONFIG['pantry']['security_groups_prefix']}([a-zA-Z0-9])+-([A-Z0-9]{12,13})\Z/

  def initialize(user = nil)
    @ec2 = AWS::EC2.new
    @ec2_adapter_policy = Ec2AdapterPolicy.new(user)
  end

  def amis(filter = {owners: [ 'self' ]})
    ami_groups = ec2.client.describe_images(filter)[:images_set].group_by do |ami|
      ami[:platform] ||= 'linux'
    end

    ami_groups.map do |os, amis|
      ami_options = amis.map do |ami|
        [ ami[:name], ami[:image_id] ]
      end
      [os, ami_options.sort_by(&:first)]
    end
  end

  def flavors
    CONFIG['aws']['ebs'].keys
  end

  def get_ami_attributes(ami)
    return if ami.blank?
    return unless image = ec2.client.describe_images({image_ids: [ami] })[:images_set][0]
    image[:platform] ||= 'linux'
    image
  end

  def platform_for_ami(ami, all_images)
    return if ami.blank?
    images = ec2.images
    images = images.with_owner('self') unless all_images
    image = images[ami]

    return unless image.exists?
    platform = image.platform

    platform == "windows" ? 'windows' : 'linux'
  end

  def security_groups
    groups = ec2.client.describe_security_groups(
      :filters => [ { :name =>"vpc-id",
                      :values => [CONFIG['aws']['vpc_id']] } ]
    )[:security_group_info].map do |group|
      [ group[:group_name], group[:group_id] ]
    end.sort

    groups.select! {|(name, _)| name[SECURITY_GROUPS_REGEX] } unless @ec2_adapter_policy.show_all_security_groups?
    groups.delete_if {|(_, id)| id == CONFIG['aws']['security_group_linux'] || id == CONFIG['aws']['security_group_windows']}
  end

  def subnets
    if @ec2_adapter_policy.show_all_subnets?
      ec2.subnets
    else
      ec2.subnets.filter("tag:Network", "Private*")
    end.map{|s| [s.tags["Name"] || s.id, s.id]}
  end
end

