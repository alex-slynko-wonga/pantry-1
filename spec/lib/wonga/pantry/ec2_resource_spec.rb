require 'spec_helper'

describe Wonga::Pantry::Ec2Resource do
  let(:ec2_instance)  { FactoryGirl.create(:ec2_instance) }
  let(:user)          { ec2_instance.user }
  let(:start_sns)     { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  let(:stop_sns)      { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  subject             { described_class.new(ec2_instance, user, start_sns, stop_sns)}

  context "#stop" do
    before(:each) do 
      ec2_instance.state = "ready"
    end

    it "sends a stop message via sns publisher" do
      stop_sns.stub(:publish_message)
      subject.stop
      expect(ec2_instance.state).to eq("shutting_down")
    end
  end

  context "#start" do
    before(:each) do 
      ec2_instance.state = "shutdown"      
    end

    it "sends a start message via sns publisher" do
      start_sns.stub(:publish_message)      
      subject.start
      expect(ec2_instance.state).to eq("starting")
    end
  end
end
