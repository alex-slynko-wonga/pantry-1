require 'spec_helper'

RSpec.describe Wonga::Pantry::Ec2InstanceMachine do
  let(:ec2_instance) { FactoryGirl.build_stubbed(:ec2_instance) }
  # before(:each) do
  #  ec2_instance = FactoryGirl.build_stubbed(:ec2_instance)
  # end

  subject { described_class.new(ec2_instance) }

  describe 'booting process' do
    context 'when it is started for the first time' do
      it 'starts the booting process' do
        expect(ec2_instance.state).to eq 'initial_state'
        subject.ec2_boot
        expect(subject).to be_booting
      end

      it 'completes the booting process' do
        ec2_instance.attributes = { dns: false, terminated: false, bootstrapped: false, joined: false }
        move_status [:ec2_boot]
        expect(subject).to be_booting
        subject.ec2_booted
        expect(subject).to be_booted
      end

      it 'adds the instance to a domain' do
        ec2_instance.attributes = { dns: false, terminated: false, bootstrapped: false, joined: true }
        move_status [:ec2_boot, :ec2_booted]
        expect(subject).to be_booted
        subject.add_to_domain
        expect(subject).to be_added_to_domain
      end

      it 'creates the DNS record' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: false, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain]
        expect(subject).to be_added_to_domain
        subject.create_dns_record
        expect(subject).to be_dns_record_created
      end

      it 'bootstraps the instance' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record]
        expect(subject).to be_dns_record_created
        subject.bootstrap
        expect(subject).to be_ready
      end
    end
  end

  describe 'shut down an instance' do
    context 'instance not protected' do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false, state: 'ready') }
      # before(:each) do
      #  ec2_instance = FactoryGirl.build(:ec2_instance, protected: false, state: 'ready')
      # end

      it 'starts the shut down process' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap]
        expect(subject).to be_ready
        subject.shutdown_now
        expect(subject).to be_shutting_down
      end

      it 'changes the status to shutdown' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now]
        expect(subject).to be_shutting_down
        subject.shutdown
        expect(subject).to be_shutdown
      end
    end

    context 'when instance is protected' do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'ready') }

      it 'does not start the shut down process' do
        expect(subject.can_termination?).to be_falsey
        subject.termination
        expect(subject).not_to be_terminating
        expect(subject).to_not be_can_termination
      end
    end
  end

  describe 'shut down automatically an instance' do
    context 'instance not protected' do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false, state: 'ready') }

      it 'starts the shut down automatically process' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap]
        expect(subject).to be_ready
        subject.shutdown_now_automatically
        expect(subject).to be_shutting_down_automatically
      end

      it 'changes the status to shutdown_automatically' do
        ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now_automatically]
        expect(subject).to be_shutting_down_automatically
        subject.shutdown
        expect(subject).to be_shutdown_automatically
      end
    end
  end

  describe 'start an instance' do
    let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'shutdown') }

    it 'starts an instance' do
      ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown
      ]
      expect(subject).to be_shutdown
      subject.start_instance
      expect(subject).to be_starting
    end

    it 'starts an instance from shutdown_automatically state' do
      ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true, state: 'shutdown_automatically' }
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now_automatically
      ]
      expect(subject).to be_shutdown_automatically
      subject.start_instance
      expect(subject).to be_starting
    end

    it 'puts the status to ready' do
      ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown, :start_instance
      ]
      expect(subject).to be_starting
      subject.started
      expect(subject).to be_ready
    end
  end

  describe 'start an instance automatically' do
    let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'shutdown_automatically') }

    it 'starts an instance from shutdown_automatically state' do
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now_automatically
      ]
      expect(subject).to be_shutdown_automatically
      subject.start_instance_automatically
      expect(subject).to be_starting
    end

    it 'puts the status to ready' do
      ec2_instance.attributes = { dns: true, terminated: false, bootstrapped: true, joined: true }
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown, :start_instance
      ]
      expect(subject).to be_starting
      subject.started
      expect(subject).to be_ready
    end
  end

  describe 'instance termination' do
    context 'instance not protected' do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false, state: 'ready') }
      # before(:each) do
      #  ec2_instance = FactoryGirl.build(:ec2_instance, protected: false, state: 'ready')
      # end

      it 'starts the termination' do
        subject.termination
        expect(subject).to be_terminating
      end

      it 'puts the instance to terminated' do
        ec2_instance.state = 'terminating'
        ec2_instance.attributes = { dns: false, terminated: true, bootstrapped: false, joined: false }
        subject.terminated
        expect(subject).to be_terminated
      end
    end

    context 'instance is protected' do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'ready') }
      # before(:each) do
      #  ec2_instance = FactoryGirl.build(:ec2_instance, protected: true, state: 'ready')
      # end

      it 'should not put the instance to terminated' do
        expect(subject).to_not be_can_termination
      end
    end

    context 'jenkins slaves termination' do
      let(:team) { FactoryGirl.create(:team) }
      let(:user) { FactoryGirl.create(:user, team: team) }
      let(:jenkins_server) { FactoryGirl.build_stubbed(:jenkins_server, :running, team: team) }
      let(:jenkins_slave) { FactoryGirl.build_stubbed(:jenkins_slave, jenkins_server: jenkins_server) }
      let(:subject_with_jenkins_slave) { described_class.new(jenkins_slave.ec2_instance) }
      let(:destroyer) { instance_double('Wonga::Pantry::JenkinsSlaveDestroyer') }

      before(:each) do
        allow(Wonga::Pantry::JenkinsSlaveDestroyer).to receive(:new).with(jenkins_slave,
                                                                          "#{jenkins_server.ec2_instance.name}.#{jenkins_server.ec2_instance.domain}",
                                                                          80,
                                                                          user).and_return(destroyer)
        allow(destroyer).to receive(:delete)
      end

      it 'sends message to destroy jenkins slave when slave is available' do
        jenkins_slave.ec2_instance.state = 'terminating'
        jenkins_slave.ec2_instance.attributes = { dns: false, terminated: true, bootstrapped: false, joined: false, protected: false }

        expect(destroyer).to receive(:delete)

        subject_with_jenkins_slave.user = user
        subject_with_jenkins_slave.fire_state_event('terminated')
        subject_with_jenkins_slave.callback
      end

      it 'does not send message to destroy jenkins slave when slave is unavailable' do
        allow(Wonga::Pantry::JenkinsSlaveDestroyer).to receive(:new).and_return(destroyer)
        allow(destroyer).to receive(:delete)

        ec2_instance.state = 'terminating'
        ec2_instance.attributes = { dns: false, terminated: true, bootstrapped: false, joined: false, protected: false }

        expect(destroyer).not_to receive(:delete)

        subject.fire_state_event('terminated')
        subject.callback
      end

    end
  end

  def move_status(transitions)
    transitions.each { |t| subject.fire_state_event(t) }
  end
end
