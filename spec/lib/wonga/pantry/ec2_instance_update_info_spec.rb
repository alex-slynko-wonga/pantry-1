require 'spec_helper'

RSpec.shared_examples_for 'logs instance attribute updates' do
  it 'logs updated to instance attributes' do
    expect(ec2_instance.ec2_instance_logs).to receive(:build).with(kind_of(Hash))
    subject.update_attributes
  end
end

RSpec.shared_examples_for 'logs instance state updates' do
  it 'logs updates to instance state' do
    expect(ec2_instance.ec2_instance_logs).to receive(:build).with(kind_of(Hash))
    subject.update_attributes
  end
end

RSpec.shared_examples_for 'does not update instance record' do
  it 'does not save instance record' do
    expect(ec2_instance).to_not receive(:save)
    subject.update_state
  end

  it 'does not log instance updates' do
    expect(ec2_instance.ec2_instance_logs).to_not receive(:build)
    subject.update_state
  end
end

RSpec.describe Wonga::Pantry::Ec2InstanceUpdateInfo do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running) }
  let(:aws_instance) { aws_ec2_mocker_build_instance }
  let(:subject) { described_class.new(ec2_instance, aws_instance) }

  describe '#update_attributes' do
    context 'if instance not changed' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :running,
                                      security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                      instance_type: ec2_instance.flavor,
                                      api_termination_disabled?: ec2_instance.protected,
                                      private_ip_address: ec2_instance.ip_address)
      end

      it 'does not save the record' do
        expect(ec2_instance).to_not receive(:save)
        subject.update_attributes
      end

      it 'does not log instance updates' do
        expect(ec2_instance.ec2_instance_logs).to_not receive(:build)
        subject.update_attributes
      end
    end

    context 'if instance is changed' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :stopping,
                                      instance_type: 'm0.tiny',
                                      api_termination_disabled?: true,
                                      security_groups: [aws_ec2_mocker_build_sg(security_group_id: 'sg-00000303'),
                                                        aws_ec2_mocker_build_sg(security_group_id: 'sg-00000404')],
                                      private_ip_address: '192.168.168.191')
      end
      it 'updates flavor field' do
        subject.update_attributes
        expect(ec2_instance.flavor).to eq(aws_instance.instance_type)
      end

      it 'updates termination protection field' do
        subject.update_attributes
        expect(ec2_instance.protected).to eq(aws_instance.api_termination_disabled?)
      end

      it 'updates security group ids field' do
        subject.update_attributes
        expect(ec2_instance.security_group_ids).to eq(['sg-00000303', 'sg-00000404'])
      end

      it 'saves the ip_address field' do
        subject.update_attributes
        expect(ec2_instance.ip_address).to eq(aws_instance.private_ip_address)
      end

      it 'saves the record field' do
        subject.update_attributes
        expect(ec2_instance).to_not be_changed
      end

      include_examples 'logs instance attribute updates'
    end

    context 'if AWS instance is terminated' do
      let(:aws_instance) { aws_ec2_mocker_build_instance(status: :terminated) }
      it 'updates terminated flag' do
        subject.update_attributes
        expect(ec2_instance.terminated).to eq(true)
      end

      context 'and ec2 instance is protected' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, protected: true) }

        it 'removes protection' do
          subject.update_attributes
          expect(ec2_instance.protected).to be false
        end

        include_examples 'logs instance attribute updates'
      end
    end
  end

  describe '#update_state' do
    context 'if AWS instance is pending' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :pending,
                                      security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                      instance_type: ec2_instance.flavor,
                                      api_termination_disabled?: ec2_instance.protected,
                                      private_ip_address: ec2_instance.ip_address)
      end

      context 'when Pantry record is in booting state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'booting') }

        include_examples 'does not update instance record'
      end

      context 'when Pantry record is in ready state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'ready') }

        it 'transitions to starting state' do
          expect(ec2_instance).to receive(:save).at_least(:once)
          subject.update_state
          expect(ec2_instance.state).to eq 'starting'
        end
      end
    end

    context 'if AWS instance is running' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :running,
                                      security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                      instance_type: ec2_instance.flavor,
                                      api_termination_disabled?: ec2_instance.protected,
                                      private_ip_address: ec2_instance.ip_address)
      end

      context 'when Pantry record is in booting state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'booting') }

        include_examples 'does not update instance record'
      end

      context 'when Pantry record is in ready state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'ready') }

        include_examples 'does not update instance record'
      end
    end

    context 'if AWS instance is terminating' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :shutting_down,
                                      security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                      instance_type: ec2_instance.flavor,
                                      api_termination_disabled?: ec2_instance.protected,
                                      private_ip_address: ec2_instance.ip_address)
      end

      context 'when Pantry record is in terminating state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'terminating') }

        include_examples 'does not update instance record'
      end

      context 'when Pantry record is in terminated state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :terminated) }

        include_examples 'does not update instance record'
      end
    end

    context 'if AWS instance is terminated' do
      let(:aws_instance) do
        aws_ec2_mocker_build_instance(status: :terminated,
                                      security_groups: ec2_instance.security_group_ids.map { |id| aws_ec2_mocker_build_sg(security_group_id: id) },
                                      instance_type: ec2_instance.flavor,
                                      api_termination_disabled?: ec2_instance.protected,
                                      private_ip_address: ec2_instance.ip_address)
      end

      context 'when Pantry record is in terminating state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, state: 'terminating') }

        include_examples 'does not update instance record'
      end

      context 'when Pantry record is in terminated state' do
        let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :terminated) }

        include_examples 'does not update instance record'
      end
    end
  end
end
