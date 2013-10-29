require 'spec_helper'

describe Wonga::Pantry::SNSPublisher do
  let(:topic_name) { "test" }
  subject { Wonga::Pantry::SNSPublisher.new(topic_name) }

  context "#publish" do
    let(:message) { { test: :test } }
    it "publishes event using SNS" do
      topic = AWS::SNS::Topic.new(topic_name)
      expect(topic).to receive(:publish).with("{\"test\":\"test\"}")
      AWS::SNS.stub_chain(:new, :topics).and_return(topic_name => topic)
      subject.publish_message(message)
    end
  end
end

