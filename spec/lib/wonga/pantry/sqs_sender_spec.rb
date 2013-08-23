require 'spec_helper'

describe Wonga::Pantry::SQSSender do
  let(:ec2) { FactoryGirl.create(:ec2_instance)}
  let(:message) { ec2.boot_message }
  subject { described_class.new() }  

  describe 'request existing jenkins server' do 
    it "creates new resource, sends message to AWS and redirects to resource" do
    client = AWS::SQS.new.client
    resp = client.stub_for(:get_queue_url)
    resp[:queue_url] = "some_url"

    client.should_receive(:send_message) do |msg|
      JSON.parse(msg[:message_body])
      AWS::Core::Response.new
    end

    subject.send_message(message)
    end
  end
end