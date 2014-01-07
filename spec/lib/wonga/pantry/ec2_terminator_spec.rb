require 'spec_helper'

describe Wonga::Pantry::Ec2Terminator do
  let!(:ec2_instance) { FactoryGirl.build(:ec2_instance, :running, user: user, team: team) }
  subject { described_class.new(ec2_instance, sns_publisher) }
  let(:user) { FactoryGirl.build(:user, team: team) }
  let(:team) { FactoryGirl.build(:team) }
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }

  context "#terminate" do
    let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true)}

    before(:each) do
      Wonga::Pantry::Ec2InstanceState.stub(:new).with(ec2_instance, user, { 'event' => "termination" }).and_return(ec2_instance_state)
    end

    it "changes state" do
      subject.terminate(user)
      expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
    end

    it "sends message via SQS" do
      subject.terminate(user)
      expect(sns_publisher).to have_received(:publish_message)
    end

    context "when machine can not be terminated" do
      let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: false)}

      it "does nothing" do
        subject.terminate(user)
        expect(sns_publisher).to_not have_received(:publish_message)
        expect(Wonga::Pantry::Ec2InstanceState).to have_received(:new)
      end
    end

    context "when user doesn't belong to team" do
      it "does nothing" do
        expect(Wonga::Pantry::Ec2InstanceState).to_not receive(:new)
        user.teams = []
        user.team_members = []
        subject.terminate(user)
        expect(sns_publisher).to_not have_received(:publish_message)
      end
    end
  end
end
