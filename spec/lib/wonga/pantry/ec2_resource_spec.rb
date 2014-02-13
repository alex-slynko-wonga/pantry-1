require 'spec_helper'

describe Wonga::Pantry::Ec2Resource do
  let(:ec2_instance)  { FactoryGirl.create(:ec2_instance) }
  let(:user)          { ec2_instance.user }
  let(:start_sns)     { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  let(:stop_sns)      { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  subject             { described_class.new(ec2_instance, user, start_sns, stop_sns)}

  context "#resize" do
    let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher', publish_message: true) }
    let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true)}
    let(:size) { 'm1.small' }

    before(:each) do
      allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).with(ec2_instance, user, { 'event' => "resize" }).and_return(ec2_instance_state)
    end

    it "changes state" do
      subject.resize(size, sns_publisher)
      expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
    end

    it "sends message via SNS" do
      subject.resize(size, sns_publisher)
      expect(sns_publisher).to have_received(:publish_message).with(hash_including(flavor: size))
    end

    context "when machine can not be resized" do
      let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: false)}
      let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher') }

      it "does nothing" do
        subject.resize(size, sns_publisher)
        expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
      end
    end

    context "when size is not in config" do
      let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher') }

      before(:each) do
        config = Marshal.load(Marshal.dump(CONFIG))
        config['aws']['ebs'] = {}
        stub_const('CONFIG', config)
      end

      it "does nothing" do
        subject.resize(size, sns_publisher)
        expect(Wonga::Pantry::Ec2InstanceState).to_not have_received(:new)
      end
    end
  end

  context "#terminate" do
    let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
    let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true)}

    before(:each) do
      allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).with(ec2_instance, user, { 'event' => "termination" }).and_return(ec2_instance_state)
    end

    it "changes state" do
      subject.terminate(sns_publisher)
      expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
    end

    it "sends message via SNS" do
      subject.terminate(sns_publisher)
      expect(sns_publisher).to have_received(:publish_message)
    end

    context "when machine can not be terminated" do
      let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: false)}

      it "does nothing" do
        subject.terminate(sns_publisher)
        expect(sns_publisher).to_not have_received(:publish_message)
        expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
      end
    end
  end

  context "#stop" do
    let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true)}

    before(:each) do
      expect(Wonga::Pantry::Ec2InstanceState).to receive(:new).with(ec2_instance, user, { 'event' => "shutdown_now" }).and_return(ec2_instance_state)
    end

    it "sends a stop message via sns publisher" do
      expect(stop_sns).to receive(:publish_message)
      expect(subject.stop).to be_truthy
    end
  end

  context "#start" do
    let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true)}

    before(:each) do
      expect(Wonga::Pantry::Ec2InstanceState).to receive(:new).with(ec2_instance, user, { 'event' => "start_instance" }).and_return(ec2_instance_state)
    end

    it "sends a start message via sns publisher" do
      expect(start_sns).to receive(:publish_message)
      expect(subject.start).to be_truthy
    end
  end
end
