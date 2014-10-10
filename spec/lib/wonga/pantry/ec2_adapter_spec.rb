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
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{ platform: 'windows' }]
      images[:image_index] = { 'test' => { platform: 'windows' } }
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

  describe '#generate_volumes' do
    shared_examples_for 'valid volumes' do
      it 'generates valid volumes' do
        instance = Ec2Instance.new
        volumes.each { |volume| volume.ec2_instance = instance }
        expect(volumes.all?(&:valid?)).to be true
      end
    end

    let(:volumes) { subject.generate_volumes('ami', nil) }
    let(:volume_size) { 50 }
    let(:device_name) { '/dev/sda1' }
    let(:block_devices) do
      [
        {
          device_name: device_name,
          ebs: { snapshot_id: 'snap-00110011', volume_size: volume_size, delete_on_termination: false, volume_type: 'standard', encrypted: false }
        }
      ]
    end
    let(:platform) { 'windows' }

    before(:each) do
      images = client.new_stub_for(:describe_images)
      allow(client).to receive(:describe_images).and_return(images)
      images[:images_set] = [{ platform: platform, block_device_mapping: block_devices }]
      images[:image_index] = { 'ami' => { platform: platform, block_device_mapping: block_devices  } }
    end

    include_examples 'valid volumes'

    it 'generates at least one volume' do
      expect(volumes.size).to be 1
    end

    it 'sets disk size from mapping' do
      expect(volumes.first.size).to eq volume_size
    end

    it 'sets disk name from mapping' do
      expect(volumes.first.device_name).to eq device_name
    end

    context 'when size provided is bigger then required for image' do
      let(:volumes) { subject.generate_volumes('ami', 500) }

      it 'sets disk size' do
        expect(volumes.first.size).to eq 500
      end

      include_examples 'valid volumes'
    end

    context 'when size in params less then required' do
      let(:volumes) { subject.generate_volumes('ami', 5) }

      it 'sets disk name from mapping' do
        expect(volumes.first.device_name).to eq device_name
      end

      include_examples 'valid volumes'
    end

    context 'when several sizes provided' do
      let(:volumes) { subject.generate_volumes('ami', 50, 30) }

      context 'when several disks exist in mapping' do
        let(:block_devices) do
          [
            {
              device_name: device_name,
              ebs: { snapshot_id: 'snap-00110011', volume_size: volume_size, delete_on_termination: false, volume_type: 'standard', encrypted: false }
            },
            {
              device_name: 'xvdz',
              ebs: { snapshot_id: 'snap-00110011', volume_size: volume_size, delete_on_termination: false, volume_type: 'standard', encrypted: false }
            }
          ]
        end

        it 'sets names from mapping' do
          expect(volumes.last.device_name).to eq('xvdz')
        end

        include_examples 'valid volumes'
      end

      context 'when mapping with ephemeral drives provided' do
        let(:block_devices) do
          [
            {
              device_name: device_name,
              ebs: { snapshot_id: 'snap-00110011', volume_size: volume_size, delete_on_termination: false, volume_type: 'standard', encrypted: false }
            },
            { device_name: 'xvdca', virtual_name: 'ephemeral0' }
          ]
        end

        it 'ignores mapping for ephemeral drives' do
          expect(volumes.last.device_name).not_to eq('xvdca')
        end

        include_examples 'valid volumes'
      end

      context 'when only one mapping exists' do
        let(:volumes) { subject.generate_volumes('ami', 30, 30, 30) }
        context 'when ami platform is windows' do
          let(:platform) { 'windows' }

          it 'sets xvdg as name' do
            expect(volumes.last.device_name).to eq('xvdg')
          end

          include_examples 'valid volumes'
        end

        context 'when ami platform is linux' do
          let(:platform) { nil }

          it 'sets /dev/sdg as name' do
            expect(volumes.last.device_name).to eq('/dev/sdg')
          end

          include_examples 'valid volumes'
        end
      end
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
