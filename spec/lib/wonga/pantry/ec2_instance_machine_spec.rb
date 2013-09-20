require 'spec_helper'

describe Wonga::Pantry::Ec2InstanceMachine do
  let(:ec2_instance) { FactoryGirl.build_stubbed(:ec2_instance) }

  subject { described_class.new(ec2_instance) }

  describe "booting process" do
    context "when it is started for the first time" do
      it "starts the booting process" do
        expect(ec2_instance.state).to eq "initial_state"
        subject.ec2_boot
        expect(subject).to be_booting
      end

      it "completes the booting process" do
        move_status [:ec2_boot]
        expect(ec2_instance.state).to eq "booting"
        subject.ec2_booted
        expect(subject).to be_booted
      end

      it "adds the instance to a domain" do
        move_status [:ec2_boot, :ec2_booted]
        expect(subject).to be_booted
        subject.add_to_domain
        expect(subject).to be_added_to_domain
      end

      it "creates the DNS record" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain]
        expect(subject).to be_added_to_domain
        subject.create_dns_record
        expect(subject).to be_dns_record_created
      end

      it "bootstraps the instance" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record]
        expect(subject).to be_dns_record_created
        subject.bootstrap
        expect(subject).to be_ready
      end
    end
  end

  describe "shut down an instance" do
    context "instance not protected" do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false, state: 'ready') }

      it "starts the shut down process" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap]
        expect(subject).to be_ready
        subject.shutdown_now
        expect(subject).to be_shutting_down
      end

      it "changes the status to shutdown" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now]
        expect(subject).to be_shutting_down
        subject.shutdown
        expect(subject).to be_shutdown
      end
    end

    context "instance is protected" do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'ready') }

      it "does not start the shut down process" do
        expect(subject.can_termination?).to be_falsey
        subject.termination
        expect(subject).not_to be_terminating
        expect(subject).to_not be_can_termination
      end
    end
  end

  describe "start a instance" do

    it "starts an instance" do
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown
      ]
      expect(subject).to be_shutdown
      subject.start_instance
      expect(subject).to be_starting
    end

    it "puts the status to ready" do
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown, :start_instance
      ]
      expect(subject).to be_starting
      subject.started
      expect(subject).to be_ready
    end
  end

  describe "instance termination" do
    context "instance not protected" do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false, state: 'ready') }

      it "starts the termination" do
        subject.termination
        expect(subject).to be_terminating
      end

      it "puts the instance to terminated" do
        ec2_instance.state = 'terminating'
        ec2_instance.attributes = { dns: false, terminated: true, bootstrapped: false, joined: false }
        subject.terminated
        expect(subject).to be_terminated
      end
    end

    context "instance is protected" do
      let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: true, state: 'ready') }

      it "should not put the instance to terminated" do
        expect(subject).to_not be_can_termination
      end
    end
  end

  def move_status(transitions)
    transitions.each {|t| subject.fire_state_event(t)}
  end
end
