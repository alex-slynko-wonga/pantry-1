require 'spec_helper'

RSpec.describe Wonga::Pantry::ChefUtility do
  let(:sns_publisher) { instance_double('Wonga::Pantry::SNSPublisher', publish_message: true) }
  let(:team) { FactoryGirl.build_stubbed(:team) }
  let(:environment) { FactoryGirl.build(:environment) }

  before :each do
    allow(Wonga::Pantry::SNSPublisher).to receive(:new).and_return(sns_publisher)
  end

  describe '#request_chef_environment' do
    it 'sends an SNS message to chef env daemon' do
      allow(sns_publisher).to receive(:publish_message) do |message|
        expect(message[:team_name]).to eq(team.name)
        expect(message[:team_id]).to eq(team.id)
        expect(message).to have_key(:domain)
      end
      subject.request_chef_environment(team, environment)
      expect(sns_publisher).to have_received(:publish_message)
    end

    it 'includes users in message' do
      user = FactoryGirl.build_stubbed :user
      team.users  = [user]

      allow(sns_publisher).to receive(:publish_message) do |message|
        expect(message[:users]).to eq([user.username])
      end
      subject.request_chef_environment(team, environment)
    end
  end
end
