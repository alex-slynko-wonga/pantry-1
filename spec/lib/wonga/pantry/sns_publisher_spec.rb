require 'spec_helper'

RSpec.describe Wonga::Pantry::SNSPublisher do
  let(:topic_name) { 'test' }
  subject { Wonga::Pantry::SNSPublisher.new(topic_name) }

  context '#publish' do
    let(:message) { { test: :test } }
    it 'publishes event using SNS' do
      topic = AWS::SNS::Topic.new(topic_name)
      expect(topic).to receive(:publish).with("{\"test\":\"test\"}")
      allow(AWS::SNS).to receive(:new).and_return(instance_double('AWS::SNS', topics: { topic_name => topic }))
      subject.publish_message(message)
    end
  end
end
