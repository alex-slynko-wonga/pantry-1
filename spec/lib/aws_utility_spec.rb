require 'spec_helper'

describe 'AWSUtility' do
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user) }
  let(:existing_jenkins) { FactoryGirl.create(:jenkins_server)}
  let(:jenk_params) {
    {
      team_id: existing_jenkins.team_id,
      user_id: 1
    }
  }
  let(:ec2_params) { 
    FactoryGirl.attributes_for(:ec2_instance).merge(
      { team_id: team.id, user_id: user.id }
    ) 
  }
  let(:jenk_params_new) { 
    ec2_params.merge(FactoryGirl.attributes_for(:jenkins_server)) 
  }

  before(:each) do 
    client = AWS::SQS::Client.new
    resp = client.stub_for(:get_queue_url)
    resp[:queue_url] = "https://sqs.eu-west-1.amazonaws.com/000000000000/blop"
    resp = client.stub_for(:send_message)
    @aws_utility = Wonga::AWSUtility.new(client) 
  end

  describe 'request_instance' do 
    it "requests an ec2 instance" do
      @aws_utility.request_instance(ec2_params).should be_an_instance_of Ec2Instance
    end
  end

  describe 'request existing jenkins server' do 
    it "returns false when a team requests a second server" do
      @aws_utility.request_jenkins_server(jenk_params).should be_false
    end

    it "requests an instance when a team requests a first server" do
      @aws_utility.request_jenkins_server(jenk_params_new).should be_an_instance_of JenkinsServer
    end
  end
end