require 'spec_helper'

describe Wonga::Pantry::ChefUtility do
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }
  let(:team) { FactoryGirl.build(:team) }
  subject { described_class.new() }

  before :each do 
    Wonga::Pantry::SQSSender.stub(:new).and_return(sqs_sender)
  end

  describe "#request_chef_environment" do
    it "sends an SQS message to chef env daemon" do
      subject.request_chef_environment(team)
      expect(sqs_sender).to have_received(:send_message)            
    end
  end

  describe "#create_environment_message" do
    it "creates a suitable env request message" do
      expect(
        subject.create_environment_message(team)[:team_name]
      ).to eq team.name
    end
  end
end