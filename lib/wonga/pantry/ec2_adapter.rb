class Wonga::Pantry::Ec2Adapter
  attr_reader :ec2
  def initialize(ec2 = AWS::EC2.new.client)
    @ec2 = ec2
  end

  def security_groups
    ec2.describe_security_groups(
        :filters => [ { :name =>"vpc-id",
                        :values => [CONFIG['aws']['vpc_id']] } ]
      )[:security_group_info].map do |group|
        [ group[:group_name], group[:group_id] ]
      end.sort
  end

  def subnets
    ec2.describe_subnets[:subnet_set].map { |subnet| subnet[:subnet_id] }
  end

  def flavors
    %w(
      t1.micro
      m1.small
      m1.medium
      m1.large
    )
  end

   def amis
     ami_groups = ec2.describe_images({owners: ['self']})[:images_set].group_by do |ami|
       ami[:platform] == "windows" ? 'windows' : 'linux'
     end

     ami_groups.map do |os, amis|
       ami_options = amis.map do |ami|
         [ ami[:name], ami[:image_id] ]
       end
       [os, ami_options.sort_by(&:first)]
     end
   end

   def platform_for_ami(ami)
     return unless ami
     return unless image = ec2.describe_images({owners: ['self'], image_ids: [ami] })[:images_set][0]
     platform = image[:platform]
     platform == "windows" ? 'windows' : 'linux'
   end
end

