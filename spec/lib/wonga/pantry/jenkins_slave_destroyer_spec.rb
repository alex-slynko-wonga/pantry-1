require 'spec_helper'

RSpec.describe Wonga::Pantry::JenkinsSlaveDestroyer do
  let(:jenkins_slave) { FactoryGirl.build(:jenkins_slave) }
  let(:ec2_instance) { jenkins_slave.ec2_instance }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team) }
  subject { described_class.new(jenkins_slave, 'host_name.domain', 80, user, sns_publisher) }
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher').as_null_object }
  let(:message) do
    {
      'server_fqdn' => 'host_name.domain',
      'server_port' => 80,
      'hostname' => ec2_instance.name,
      'domain' => ec2_instance.domain,
      'instance_id' => ec2_instance.instance_id,
      'id' => ec2_instance.id,
      'jenkins_slave_id' => jenkins_slave.id,
      'chef_environment' => ec2_instance.environment.chef_environment,
      'user_id' => user.id
    }
  end

  context '#destroy' do
    it 'sends message via SNS' do
      subject.delete
      expect(sns_publisher).to have_received(:publish_message).with(message)
    end
  end
end
