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

  context "#publish_error" do
    let(:text) { "error" }
    let(:topic_name) { "error_test" }

    it "publishes error text on separate channel" do
      Daemons.stub(:config).and_return({ 'sns' => { 'error_arn' => topic_name }})
      topic = AWS::SNS::Topic.new(topic_name)
      expect(topic).to receive(:publish).with(text)
      AWS::SNS.stub_chain(:new, :topics).and_return(topic_name => topic)
      subject.publish_error(text)
    end
  end
end

