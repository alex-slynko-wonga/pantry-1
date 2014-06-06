module AwsEc2Mocker

  def aws_ec2_mocker_build_instance(attributes)
    instance_double(AWS::EC2::Instance, default_ec2_instance_attributes.merge(attributes))
  end

  def aws_ec2_mocker_build_sg(attributes)
    instance_double(AWS::EC2::SecurityGroup, default_sg_attributes.merge(attributes))
  end

  def aws_ec2_mocker_build_tag(attributes)
    instance_double(AWS::EC2::Tag, default_tag_attributes.merge(attributes))
  end

  def aws_ec2_mocker_build_volume(attributes)
    instance_double(AWS::EC2::Volume, default_volume_attributes.merge(attributes))
  end

  def default_ec2_instance_attributes
    {
      api_termination_disabled?: false,
      exists?: true,
      image: "ami-00001234",
      instance_id: "i-00001234",
      instance_type: "t1.micro",
      ip_address: "16.8.4.2",
      platform: "windows",
      private_dns_name: "private.ec2.aws.stub",
      dns_name: "something.amazon.stub",
      private_ip_address: "192.168.000.000",
      security_groups: [ aws_ec2_mocker_build_sg(security_group_id: "sg-00000001"), aws_ec2_mocker_build_sg(security_group_id: "sg-00000002") ],
      status: :pending,
      status_code: 0,
      subnet_id: "subnet-00000000",
      vpc_id: "vpc-00000000"
    }
  end

# EC2 Instance States
# http://docs.aws.amazon.com/AWSEC2/latest/APIReference/ApiReference-ItemType-InstanceStateType.html
#+--------+---------------+
#|  Code  |     State     |
#+--------+---------------+
#|   0    |    pending    |
#|  16    |    running    |
#|  32    | shutting-down |
#|  48    |  terminated   |
#|  64    |   stopping    |
#|  80    |   stopped     |
#+--------+---------------+

  def default_sg_attributes
    {
      security_group_id: "sg-00000000",
      name: "A fake sg",
      description: "A fake sg",
      owner_id: "fakeownerid",
      vpc_id: "fakevpc"
    }
  end

  def default_tag_attributes
    {
      key: nil,
      resource: nil,
      value: nil
    }
  end

  def default_volume_attributes
    {
      availability_zone_name: "eu-west-1a",
      create_time: "2014-05-01 00:00:00 UTC",
      id: "vol-00000000",
      iops: 1000,
      size: 100,
      status: :attached
    }
  end
end

RSpec.configure do |config|
  config.include AwsEc2Mocker
end
