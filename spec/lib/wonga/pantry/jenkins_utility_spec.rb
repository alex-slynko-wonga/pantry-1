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
      team: team
    }
  end

  before(:each) do
    allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
    allow(ec2_resource).to receive(:boot)
  end

  describe 'request jenkins slave' do
    let!(:jenkins) { JenkinsSlave.new(jenkins_server: existing_server) }

    include_examples 'request_instance'

    it "sets platform to 'windows'" do
      expect(subject.jenkins_instance_params(jenkins)[:platform]).to eq('windows')
    end

    it 'sets jenkins_windows_agent role' do
      expect(subject.jenkins_instance_params(
        FactoryGirl.build(:jenkins_slave)
      )[:run_list]).to eq('role[jenkins_windows_agent]')
    end

    it 'sets ami-00110011' do
      expect(subject.jenkins_instance_params(
        FactoryGirl.build(:jenkins_slave)
      )[:ami]).to eq('ami-00110011')
    end
  end

  describe 'request jenkins server' do
    let(:jenkins) { JenkinsServer.new(team: team) }
    include_examples 'request_instance'
  end
end
