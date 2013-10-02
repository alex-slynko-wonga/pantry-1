require 'spec_helper'

describe Wonga::Pantry::Ec2Terminator do
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, user: user, team: team) }
  subject { described_class.new(ec2_instance, sqs_sender) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team) }
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }

  context "#terminate" do
    it "sets terminated_by" do
      subject.terminate(user)
      expect(ec2_instance.terminated_by).to eq(user)
    end

    it "sends message via SQS" do
      subject.terminate(user)
      expect(sqs_sender).to have_received(:send_message)
    end

    it "does nothing if machine is not running" do
      ec2_instance.stub(:running?).and_return(false)
      subject.terminate(user)
      expect(sqs_sender).to_not have_received(:send_message)
      expect(ec2_instance.terminated_by).to_not eq(user)
    end
  end
end
