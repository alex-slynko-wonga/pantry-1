require 'spec_helper'

shared_examples_for "request_instance" do
  it "saves jenkins instance" do
    subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )
    expect(jenkins).to be_persisted
  end

  it "requests an instance" do
    expect{
      subject.request_jenkins_instance(
        jenkins_params,
        jenkins
      )}.to change(Ec2Instance, :count).by(1)
  end

  it "sets instance_name from jenkins" do
    jenkins.stub(:instance_name).and_return('test')
    subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )
    expect(jenkins.ec2_instance.name).to eq 'test'
  end

  it "sends message to sqs using sqs_sender" do
    subject.request_jenkins_instance(
      jenkins_params,
      jenkins
    )
    expect(sqs_sender).to have_received(:send_message)
  end
end

describe Wonga::Pantry::AWSUtility do
  subject { described_class.new(sqs_sender) }
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user) }
  let(:existing_server) { FactoryGirl.create(:jenkins_server) }
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }

  let(:jenkins_params) {
    {
      user_id: user.id,
      team: team
    }
  }

  describe 'request jenkins slave' do
    let!(:jenkins) { JenkinsSlave.new(jenkins_server: existing_server) }

    include_examples 'request_instance'
  end

  describe 'request jenkins server' do
    let(:jenkins) { JenkinsServer.new(team: team) }
    include_examples 'request_instance'

    context "when team already owns one server" do
      let!(:team) { existing_server.team }

      it "saves jenkins instance" do
        subject.request_jenkins_instance(
          jenkins_params,
          jenkins
        )
        expect(jenkins).to_not be_persisted
      end

      it "does not request an instance" do 
        expect { subject.request_jenkins_instance(
          jenkins_params,
          jenkins
        )}.to_not change(Ec2Instance, :count)
      end

      it "does not send message to sqs using sqs_sender" do
        subject.request_jenkins_instance(
          jenkins_params,
          jenkins
        )
        expect(sqs_sender).to_not have_received(:send_message)
      end
    end
    
    context "when creating a new one" do
      it "creates a JenkinsServer" do
        subject.jenkins_instance_params(jenkins)[:run_list].should == "role[jenkins_linux_server]"
      end
      
      it "creates a JenkinsSlave" do
        subject.jenkins_instance_params(
        FactoryGirl.create(:jenkins_slave)
        )[:run_list].should == "role[jenkins_windows_agent]"
      end
    end
  end
end
