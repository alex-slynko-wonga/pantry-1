require 'spec_helper'

describe Wonga::Pantry::JenkinsSlaveDestroyer do
  let(:ec2_instance) { jenkins_slave.ec2_instance }
  let(:jenkins_slave) { FactoryGirl.create(:jenkins_slave) }
  let(:user) { FactoryGirl.create(:user, team: jenkins_slave.team) }
  subject { described_class.new(jenkins_slave, 'host_name.domain', 80, user, sns_publisher) }
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }

  context "#destroy" do
    it "saves the user who terminated the slave" do
      ec2_instance.should_receive(:update_attributes).with(terminated_by: user)
      Wonga::Pantry::JenkinsSlaveDestroyer.new(jenkins_slave, 'host_name.domain', 80, user, sns_publisher).delete
    end

    it "sends message via SQS" do
      subject.delete
      expect(sns_publisher).to have_received(:publish_message)
    end
  end
end
