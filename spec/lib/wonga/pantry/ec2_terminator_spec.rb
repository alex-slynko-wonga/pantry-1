require 'spec_helper'

describe Wonga::Pantry::Ec2Terminator do
  let!(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, user: user, team: team) }
  subject { described_class.new(ec2_instance, sns_publisher) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team) }
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }

  context "#terminate" do
    it "sets terminated_by" do
      subject.terminate(user)
      expect(ec2_instance.terminated_by).to eq(user)
    end

    it "sends message via SQS" do
      subject.terminate(user)
      expect(sns_publisher).to have_received(:publish_message)
    end

    it "does nothing if machine is not running" do
      ec2_instance.stub(:running?).and_return(false)
      subject.terminate(user)
      expect(sns_publisher).to_not have_received(:publish_message)
      expect(ec2_instance.terminated_by).to_not eq(user)
    end

    context "when user doesn't belong to team" do
      it "does nothing" do
        user.teams = []
        subject.terminate(user)
        expect(sns_publisher).to_not have_received(:publish_message)
        expect(ec2_instance.terminated_by).to_not eq(user)
      end
    end
  end
end
