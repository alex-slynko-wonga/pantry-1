require 'spec_helper'
require_relative "#{Rails.root}/daemons/common/publisher"

describe Publisher do
  context "#publish" do
    let(:topic_name) { "test" }
    let(:message) { { test: :test } }
    it "publishes event using SNS" do
      topic = AWS::SNS::Topic.new(topic_name)
      expect(topic).to receive(:publish).with("{\"test\":\"test\"}")
      AWS::SNS.stub_chain(:new, :topics).and_return(topic_name => topic)
      subject.publish(topic_name, message)
    end
  end
end

