require 'spec_helper'

describe Wonga::Pantry::Ec2Resource do
  let(:ec2_instance)  { FactoryGirl.create(:ec2_instance) }
  let(:user)          { ec2_instance.user }
  subject             { described_class.new(ec2_instance, user) }  
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }

  context "#stop" do
    before(:each) do 
      Wonga::Pantry::SNSPublisher.stub(:new).and_return(sns_publisher)
      ec2_instance.state = "ready"
    end

    it "sends a stop message via sns publisher" do
      subject.stop
      expect(ec2_instance.state).to eq("shutting_down")
      expect(sns_publisher).to have_received(:publish_message)
    end
  end

  context "#start" do
    before(:each) do 
      Wonga::Pantry::SNSPublisher.stub(:new).and_return(sns_publisher)
      ec2_instance.state = "shutdown"      
    end

    it "sends a start message via sns publisher" do
      subject.start
      expect(ec2_instance.state).to eq("starting")
      expect(sns_publisher).to have_received(:publish_message)
    end
  end

  context "#terminate" do
    before(:each) do 
      Wonga::Pantry::SNSPublisher.stub(:new).and_return(sns_publisher)
      ec2_instance.state = "ready"      
    end

    it "sends a terminate message via sns publisher" do
      subject.terminate
      expect(ec2_instance.state).to eq("terminating")      
      expect(sns_publisher).to have_received(:publish_message)
    end
  end
end
