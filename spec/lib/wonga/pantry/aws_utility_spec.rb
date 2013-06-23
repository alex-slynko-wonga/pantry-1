require 'spec_helper'

describe Wonga::Pantry::AWSUtility do
  let(:sqs) { Wonga::Pantry::SQSSender.new() }
  subject { described_class.new(sqs) }  
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user) }
  let(:jenkins_params) {
    {
      user_id: team.id,
      name: "TestName"
    }
  }
  let(:ec2_params) { 
    FactoryGirl.attributes_for(:ec2_instance).merge(
      { team_id: team.id, user_id: user.id }
    ) 
  }

  before(:each) do 
    client = AWS::SQS.new.client
    resp = client.stub_for(:get_queue_url)
    resp[:queue_url] = "https://sqs.eu-west-1.amazonaws.com/000000000000/blop"
    sqs_sender = Wonga::Pantry::SQSSender.new()
    @aws_utility = Wonga::Pantry::AWSUtility.new(sqs_sender) 
  end

  describe 'request existing jenkins server' do 
    it "requests an instance when a team requests a first server" do
      expect{
        subject.request_jenkins_instance(
          jenkins_params, 
          JenkinsServer.new(team_id: team.id)
        )}.to change(JenkinsServer, :count).by(1)
    end
  end
end