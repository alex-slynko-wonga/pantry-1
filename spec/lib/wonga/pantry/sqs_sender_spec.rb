require 'spec_helper'

RSpec.describe Wonga::Pantry::SQSSender do
  subject { described_class.new('queue') }
  let(:message) { instance_double(Wonga::Pantry::BootMessage, boot_message: { 'message' => 'boot' }) }

  describe '#send_message' do
    it 'sends a message to a queue' do
      client = AWS::SQS.new.client
      resp = client.stub_for(:get_queue_url)
      resp[:queue_url] = 'https://sqs.eu.amazonaws.com/fakequeue'

      expect(client).to receive(:send_message).and_call_original

      subject.send_message(message)
      resp.clear
    end
  end
end
