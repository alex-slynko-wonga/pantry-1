require 'spec_helper'

RSpec.describe Wonga::Pantry::Ec2Adapter do
  let(:role) { 'developer' }

  subject { described_class.new(User.new(role: role)) }

  let(:client) { AWS::EC2.new.client }

  context '#amis' do
    it 'returns list for select with visible images' do
      win_ami = FactoryGirl.create(:ami, platform: 'windows')
      linux_ami = FactoryGirl.create(:ami, platform: 'linux')
      amis = subject.amis
      windows = amis['windows'].first
      linux = amis['linux'].first
      expect(windows[0]).to eq win_ami.name
      expect(windows[1]).to eq win_ami.ami_id
      expect(linux[0]).to eq linux_ami.name
      expect(linux[1]).to eq linux_ami.ami_id
    end

    it 'returns list with visible images' do
      FactoryGirl.create(:ami, platform: 'linux')
      FactoryGirl.create(:ami, hidden: true, platform: 'linux')
      amis = subject.amis
      expect(amis['linux'].size).to eq 1
    end

    context 'for superadmin' do
      let(:role) { 'superadmin' }
      it 'returns list with all images' do
        FactoryGirl.create(:ami, platform: 'linux')
        FactoryGirl.create(:ami, hidden: true, platform: 'linux')
        amis = subject.amis
        expect(amis['linux'].size).to eq 2
      end
    end
  end

  context '#platform_for_ami' do
    it 'finds image and gets platform from it' do
      images = client.new_stub_for(:describe_images)
      images[:images_set] = [{ platform: 'windows' }]
      images[:image_index] = { 'test' => { platform: 'windows' } }
      allow(client).to receive(:describe_images).and_return(images)
      expect(subject.platform_for_ami('test')).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.platform_for_ami('test')).to be_nil
    end

    it 'returns nil if ami is not provided' do
      expect(subject.platform_for_ami(nil)).to be_nil
    end

    it 'returns linux if ami has no platform parameter' do
      images = client.new_stub_for(:describe_images)
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{}]
      images[:image_index] = { 'test' => {} }
      expect(subject.platform_for_ami('test')).to eq('linux')
    end
  end

  context '#get_ami_attributes' do
    it 'finds image and gets attributes for it' do
      images = client.new_stub_for(:describe_images)
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{ name: 'test-ami', platform: 'windows' }]
      expect(subject.get_ami_attributes('test')[:platform]).to eq('windows')
    end

    it "returns nil if image can't be found" do
      expect(subject.get_ami_attributes('test')).to be_nil
    end

    it 'returns nil if ami is not provided' do
      images = client.new_stub_for(:describe_images)
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{ name: 'test-ami2', platform: 'Lindows' }]
      expect(subject.get_ami_attributes(nil)).to be_nil
    end

    it 'returns linux if ami has no platform parameter' do
      images = client.new_stub_for(:describe_images)
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{ name: 'test-ami2' }]
      expect(subject.get_ami_attributes('test')[:platform]).to eq('linux')
    end
  end

  describe '#security_groups' do
    let(:security_groups) do
      [['ExampleVPC-SecurityGroupArtifactory', 'sg-00000001'],
       ['ExampleVPC-SecurityGroupAPIServer-001122334455', 'sg-00000002'],
       ['awseb-e-0123456789-stack-AWSEBLoadBalancerSecurityGroup-001122334455',
        'sg-00000003'],
       ['default', 'sg-00000000']]
    end

    before(:each) do
      allow(client).to receive_message_chain(:describe_security_groups, :[], :map, :sort).and_return(security_groups)
    end

    it 'calls describe_security_groups on the client' do
      subject.security_groups
      expect(client).to have_received(:describe_security_groups)
        .with(filters: [{ name: 'vpc-id', values: [CONFIG['aws']['vpc_id']] }])
    end

    context 'when superadmin' do
      let(:role) { 'superadmin' }

      it 'returns all groups' do
        expect(subject.security_groups).to eq security_groups
      end
    end

    context 'when developer' do
      it 'does not return a group with a generic name' do
        expect(subject.security_groups).not_to include ['default', 'sg-00000000']
      end

      it "does not return a group starting with 'ExampleVPC-SecurityGroup' only" do
        expect(subject.security_groups).not_to include ['ExampleVPC-SecurityGroupArtifactory', 'sg-00000001']
      end

      it 'does not return a group starting with the wrong prefix' do
        expect(subject.security_groups)
          .not_to include ['awseb-e-0123456789-stack-AWSEBLoadBalancerSecurityGroup-001122334455', 'sg-00000003']
      end

      it 'returns a CF group ending with 12 alpha-numeric characters' do
        expect(subject.security_groups).to include ['ExampleVPC-SecurityGroupAPIServer-001122334455', 'sg-00000002']
      end
    end
  end

  describe '#subnets' do
    let(:subnets) { double(map: []) }
    let(:ec2) { instance_double(AWS::EC2, subnets: subnets) }

    before(:each) do
      allow(AWS::EC2).to receive(:new).and_return(ec2)
    end

    context 'when user is superadmin' do
      let(:role) { 'superadmin' }
      it 'returns all subnets' do
        expect(subnets).not_to receive(:filter).with('tag:Network', 'Private*')
        subject.subnets
      end
    end

    context 'when user is developer' do
      it 'returns filtered subnets' do
        expect(subnets).to receive(:filter).with('tag:Network', 'Private*').and_return(subnets)
        subject.subnets
      end
    end
  end
end
