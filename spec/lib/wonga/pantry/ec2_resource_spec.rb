require 'spec_helper'

describe Wonga::Pantry::Ec2Resource do
  let(:ec2_instance)  { FactoryGirl.create(:ec2_instance) }
  let(:user)          { ec2_instance.user }
  let(:start_sns)     { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  let(:stop_sns)      { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  subject             { described_class.new(ec2_instance, user, start_sns, stop_sns)}

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
    before(:each) do 
      ec2_instance.state = "ready"
    end

    it "sends a stop message via sns publisher" do
      allow(stop_sns).to receive(:publish_message)
      expect(subject.stop).to be_truthy
      expect(ec2_instance.state).to eq("shutting_down")
    end
  end

  context "#start" do
    before(:each) do
      ec2_instance.state = "shutdown"
    end

    it "sends a start message via sns publisher" do
      allow(start_sns).to receive(:publish_message)
      expect(subject.start).to be_truthy
      expect(ec2_instance.state).to eq("starting")
    end
  end
end
