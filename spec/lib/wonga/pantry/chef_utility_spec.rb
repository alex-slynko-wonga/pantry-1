require 'spec_helper'

describe Wonga::Pantry::ChefUtility do
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender') }
  let(:team) { FactoryGirl.build(:team) }

  before :each do
    Wonga::Pantry::SQSSender.stub(:new).and_return(sqs_sender)
  end

  describe "#request_chef_environment" do
    it "sends an SQS message to chef env daemon" do
      team.id = 42
      sqs_sender.stub(:send_message) do |message|
        expect(message[:team_name]).to eq(team.name)
        expect(message[:team_id]).to eq(42)
        expect(message).to have_key(:domain)
      end
      subject.request_chef_environment(team)
      expect(sqs_sender).to have_received(:send_message)
    end
  end
end
