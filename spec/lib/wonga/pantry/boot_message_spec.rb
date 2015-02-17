require 'spec_helper'

RSpec.describe Wonga::Pantry::BootMessage do
  let(:instance) { FactoryGirl.build_stubbed(:ec2_instance) }

  describe '#boot_message' do
    let(:boot_message) { subject.boot_message(instance) }

    it 'splits run list and make it into array' do
      instance.run_list = "test\r\nsecond,third"
      expect(boot_message[:run_list]).to eq(%w(test second third))
    end

    it 'gets ou from Wonga::Pantry::ActiveDirectoryOU' do
      allow(Wonga::Pantry::ActiveDirectoryOU).to receive(:new).and_return(instance_double('Wonga::Pantry::ActiveDirectoryOU', ou: 'test'))
      expect(boot_message[:ou]).to eq('test')
    end

    context 'when instance is not saved' do
      let(:instance) { Ec2Instance.new }

      it 'raise exception' do
        expect { boot_message }.to raise_exception
      end
    end

    context 'when custom IAM exists' do
      it 'adds iam_instance_profile to message' do
        instance.iam_instance_profile = 'test_iam_profile'
        expect(boot_message).to include(iam_instance_profile: 'test_iam_profile')
      end
    end

    context '#bootstrap_username' do
      let(:bootstrap_username) { 'CentOS' }
      let(:ami) { Ami.new bootstrap_username: bootstrap_username }

      it 'add bootstrap_username to message' do
        expect(Ami).to receive(:where).and_return([ami])
        expect(boot_message).to include(bootstrap_username: bootstrap_username)
      end

      it 'does not add empty bootstrap_username when ami not found' do
        expect(boot_message).to_not include(:bootstrap_username)
      end

      context 'bootstrap_username is empty' do
        let(:ami) { instance_double('Ami', bootstrap_username: '') }

        it 'does not add empty bootstrap_username' do
          expect(Ami).to receive(:where).and_return([ami])
          expect(boot_message).to_not include(:bootstrap_username)
        end
      end
    end

    describe 'block_device_mappings' do
      let(:block_devices)  { boot_message[:block_device_mappings] }

      it 'processes single drive' do
        expect(block_devices).to be_one
      end

      it 'sets info from volume model' do
        volume = instance.ec2_volumes.first
        device = block_devices.first
        expect(device[:device_name]).to eq(volume.device_name)
        expect(device[:ebs][:volume_size]).to eq(volume.size)
      end

      it 'sets delete_on_termination flag' do
        expect(block_devices).to be_all { |device| device[:ebs][:delete_on_termination] }
      end

      context 'for multidrive instance' do
        let(:instance) { FactoryGirl.build_stubbed(:ec2_instance, additional_volume_size: 50) }
        let(:additional_device_info) { block_devices[1] }

        it 'sets delete_on_termination flag' do
          expect(block_devices).to be_all { |device| device[:ebs][:delete_on_termination] }
        end

        it 'processes additional drive' do
          expect(block_devices.size).to be 2
        end
      end
    end
  end
end
