require 'spec_helper'

describe Wonga::Pantry::Ec2InstanceMachine do
  let(:ec2_instance) { FactoryGirl.build(:ec2_instance, protected: false) }             
  let(:ec2_protected) { FactoryGirl.build(:ec2_instance, protected: true) }
  subject { described_class.new }

  describe "booting process" do
    before(:each) do 
      subject.ec2_instance = ec2_instance        
    end

    context "when it is started for the first time" do
      it "starts the booting process" do
        subject.state.should eq "initial_state"
        subject.ec2_boot
        subject.should be_booting
      end

      it "completes the booting process" do
        move_status [:ec2_boot]
        subject.state.should eq "booting"
        subject.ec2_booted
        subject.should be_booted
      end

      it "adds the instance to a domain" do
        move_status [:ec2_boot, :ec2_booted]
        subject.should be_booted
        subject.add_to_domain
        subject.should be_added_to_domain
      end

      it "creates the DNS record" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain]
        subject.should be_added_to_domain
        subject.create_dns_record
        subject.should be_dns_record_created
      end

      it "bootstraps the instance" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record]
        subject.should be_dns_record_created
        subject.bootstrap
        subject.should be_ready
      end
    end
  end

  describe "shut down an instance" do
    context "instance not protected" do 
      before(:each) do 
        subject.ec2_instance = ec2_instance        
      end      
      it "starts the shut down process" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap]
        subject.should be_ready
        subject.shutdown_now
        subject.should be_shutting_down
      end

      it "changes the status to shutdown" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap, :shutdown_now]
        subject.should be_shutting_down
        subject.shutdown
        subject.should be_shutdown
      end
    end

    context "instance is protected" do 
      before(:each) do 
        subject.ec2_instance = ec2_protected
      end            
      
      it "does not start the shut down process" do
        move_status [:ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record, :bootstrap]
        subject.should be_ready
        subject.shutdown_now
        subject.should_not be_shutting_down
      end
    end
  end

  describe "start a instance" do
    before(:each) do 
      subject.ec2_instance = ec2_instance        
    end

    it "starts an instance" do
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown
      ]
      subject.should be_shutdown
      subject.start_instance
      subject.should be_starting
    end

    it "puts the status to ready" do
      move_status [
        :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
        :bootstrap, :shutdown_now, :shutdown, :start_instance
      ]
      subject.should be_starting
      subject.started
      subject.should be_ready
    end
  end

  describe "instance termination" do
    before(:each) do 
      subject.ec2_instance = ec2_instance        
    end

    context "instance not protected"
      it "starts the termination" do
        move_status [
          :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
          :bootstrap, :shutdown_now, :shutdown, :start_instance, :started
        ]
        subject.should be_ready
        subject.termination
        subject.should be_terminating
      end

      it "puts the instance to terminated" do
        move_status [
          :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
          :bootstrap, :shutdown_now, :shutdown, :start_instance, :started, :termination
        ]
        subject.should be_terminating
        subject.ec2_instance = { dns: false, terminated: true, bootstrapped: false, joined: false }
        subject.terminated
        subject.should be_terminated
      end
    end

    context "instance is protected" do 
      before(:each) do 
        subject.ec2_instance = ec2_protected           
      end

      it "should not put the instance to terminated" do
        move_status [
          :ec2_boot, :ec2_booted, :add_to_domain, :create_dns_record,
          :bootstrap, :shutdown_now, :shutdown, :start_instance, :started, :termination
        ]
        subject.should_not be_terminating
      end
    end

  def move_status(transitions)
    transitions.each {|t| subject.fire_state_event(t)}
  end
end
