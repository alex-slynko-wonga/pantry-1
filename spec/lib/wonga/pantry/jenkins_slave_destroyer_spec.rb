require 'spec_helper'

describe Wonga::Pantry::JenkinsSlaveDestroyer do
  let(:jenkins_slave) { FactoryGirl.create(:jenkins_slave) }
  let(:ec2_instance) { jenkins_slave.ec2_instance }
  let(:user) { FactoryGirl.create(:user, team: jenkins_slave.team) }
  subject { described_class.new(jenkins_slave, 'host_name.domain', 80, user, sns_publisher) }
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true) }
  let(:message) {
    {
      "server_ip"=>"host_name.domain",
      "server_port"=>80,
      "hostname"=>ec2_instance.name,
      "domain"=>ec2_instance.domain,
      "instance_id"=>ec2_instance.instance_id,
      "id"=>ec2_instance.id,
      "jenkins_slave_id"=>jenkins_slave.id,
      "chef_environment"=>ec2_instance.chef_environment,
      "user_id"=>jenkins_slave.ec2_instance.user.id
    }
  }

  before(:each) do
    Wonga::Pantry::Ec2InstanceState.stub(:new).with(ec2_instance, user, { 'event' => "termination" }).and_return(ec2_instance_state)
  end

  context "#destroy" do
    it "sends message via SQS" do
      subject.delete
      expect(sns_publisher).to have_received(:publish_message).with(message)
    end
  end
end
