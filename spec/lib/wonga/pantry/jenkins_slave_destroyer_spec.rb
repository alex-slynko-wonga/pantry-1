require 'spec_helper'

describe Wonga::Pantry::JenkinsSlaveDestroyer do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance) }
  let(:user) { FactoryGirl.create(:user) }
  subject { described_class.new(ec2_instance, 'host_name.domain', 80, user, sqs_sender) }
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }

  context "#destroy" do
    it "saves the user who terminated the slave" do
      ec2_instance.should_receive(:update_attributes).with(terminated_by: user)
      Wonga::Pantry::JenkinsSlaveDestroyer.new(ec2_instance, 'host_name.domain', 80, user, sqs_sender)
    end
    
    it "sends message via SQS" do
      subject.delete
      expect(sqs_sender).to have_received(:send_message)
    end
  end
end
