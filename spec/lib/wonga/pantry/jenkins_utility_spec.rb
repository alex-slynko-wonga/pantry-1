require 'spec_helper'

RSpec.shared_examples_for 'request_instance' do
  it 'sets instance_name from jenkins' do
    allow(jenkins).to receive(:instance_name).and_return('test')
    subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )
    expect(jenkins.ec2_instance.name).to eq 'test'
  end

  it 'boots machine using ec2_resource and returns it result' do
    expect(ec2_resource).to receive(:boot).and_return(:some_result)
    expect(subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )).to eq(:some_result)
    expect(jenkins).to be_valid
  end

  it 'gets attributes from instance role' do
    subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )
    expect(jenkins.ec2_instance.instance_role).to eq instance_role
  end
end

RSpec.describe Wonga::Pantry::JenkinsUtility do
  subject { described_class.new }
  let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource') }
  let(:team) { FactoryGirl.create(:team, :with_ci_environment) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:existing_server) { FactoryGirl.create(:jenkins_server, team: team) }

  let(:jenkins_params) do
    {
      user_id: user.id,
      team_id: team.id,
      instance_role_id: instance_role.id
    }
  end

  before(:each) do
    allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
    allow(ec2_resource).to receive(:boot)
  end

  describe 'request jenkins slave' do
    let!(:jenkins) { JenkinsSlave.new(jenkins_server: existing_server) }
    let(:instance_role) { FactoryGirl.create(:instance_role, :for_jenkins_slave) }

    include_examples 'request_instance'
  end

  describe 'request jenkins server' do
    let(:jenkins) { JenkinsServer.new(team: team) }
    let(:instance_role) { FactoryGirl.create(:instance_role, :for_jenkins_server) }
    include_examples 'request_instance'
  end
end
