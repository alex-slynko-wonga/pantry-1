require 'spec_helper'

describe Wonga::Pantry::Ec2Adapter do
  let(:role) { 'developer' }

  subject { described_class.new(User.new(role: role)) }

  let(:client) { AWS::EC2.new.client }

  after(:each) do
    client.instance_variable_set(:@stubs, {})
  end

  context "#platform_for_ami" do
    it "finds image and gets platform from it" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'windows'}]
      images[:image_index] = { 'test' => {:platform => 'windows'}}
      expect(subject.platform_for_ami('test', false)).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.platform_for_ami('test', false)).to be_nil
    end

    it "returns nil if ami is not provided" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:platform => 'windows'}]
      images[:image_index] = { 'test' => {:platform => 'windows'}}
      expect(subject.platform_for_ami(nil, false)).to be_nil
    end

    it "returns linux if ami has no platform parameter" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{ }]
      images[:image_index] = { 'test' => {}}
      expect(subject.platform_for_ami('test', false)).to eq('linux')
    end
  end

  context "#get_ami_attributes" do
    it "finds image and gets attributes for it" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:name => 'test-ami', :platform => 'windows'}]
      expect(subject.get_ami_attributes('test')[:platform]).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.get_ami_attributes('test')).to be_nil
    end

    it "returns nil if ami is not provided" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{:name => 'test-ami2', :platform => 'Lindows'}]
      expect(subject.get_ami_attributes(nil)).to be_nil
    end

    it "returns linux if ami has no platform parameter" do
      images = client.stub_for(:describe_images)
      images[:images_set] = [{ :name => 'test-ami2' }]
      expect(subject.get_ami_attributes('test')[:platform]).to eq('linux')
    end
  end

  describe "#security_groups" do
    let(:security_groups) {
      [["ExampleVPC-SecurityGroupAPIServer-001122334455", "sg-00000002"],
       ["ExampleVPC-SecurityGroupArtifactory", "sg-00000001"],
       ["awseb-e-0123456789-stack-AWSEBLoadBalancerSecurityGroup-001122334455",
        "sg-00000003"],
       ["default", "sg-00000000"]]
    }

    it "calls describe_security_groups on the client" do
      subject.security_groups
      expect(client).to have_received(:describe_security_groups)
        .with(:filters => [ { :name =>"vpc-id", :values => [CONFIG['aws']['vpc_id']] } ])
    end

    before(:each) do
      client.stub_chain(:describe_security_groups, :[], :map, :sort).and_return(security_groups)
    end

    context "when superadmin" do
      let(:role) { 'superadmin' }

      it "returns all groups" do
        expect(subject.security_groups).to eq security_groups
      end
    end

    context "when developer" do
      it "does not return a group with a generic name" do
        expect(subject.security_groups).not_to include ["default", "sg-00000000"]
      end

      it "does not return a group starting with 'ExampleVPC-SecurityGroup' only" do
        expect(subject.security_groups).not_to include ["ExampleVPC-SecurityGroupArtifactory", "sg-00000001"]
      end

      it "does not return a group starting with the wrong prefix" do
        expect(subject.security_groups)
          .not_to include ["awseb-e-0123456789-stack-AWSEBLoadBalancerSecurityGroup-001122334455", "sg-00000003"]
      end

      it "returns a CF group ending with 12 alpha-numeric characters" do
        expect(subject.security_groups).to include ["ExampleVPC-SecurityGroupAPIServer-001122334455", "sg-00000002"]
      end
    end
  end
end
