require 'spec_helper'

RSpec.describe Wonga::Pantry::ChefUtility do
  let(:sqs_sender) { instance_double('Wonga::Pantry::SQSSender', send_message: true) }
  let(:team) { FactoryGirl.build_stubbed(:team) }
  let(:environment) { FactoryGirl.build(:environment) }

  before :each do
    allow(Wonga::Pantry::SQSSender).to receive(:new).and_return(sqs_sender)
  end

  describe '#request_chef_environment' do
    it 'sends an SQS message to chef env daemon' do
      allow(sqs_sender).to receive(:send_message) do |message|
        expect(message[:team_name]).to eq(team.name)
        expect(message[:team_id]).to eq(team.id)
        expect(message).to have_key(:domain)
      end
      subject.request_chef_environment(team, environment)
      expect(sqs_sender).to have_received(:send_message)
    end

    it 'includes users in message' do
      user = FactoryGirl.build_stubbed :user
      team.users  = [user]

      allow(sqs_sender).to receive(:send_message) do |message|
        expect(message[:users]).to eq([user.username])
      end
      subject.request_chef_environment(team, environment)
    end
  end
end
