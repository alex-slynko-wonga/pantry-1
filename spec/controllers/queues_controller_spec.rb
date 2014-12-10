require 'spec_helper'

RSpec.describe QueuesController, type: :controller do
  before(:each) do
    allow(subject).to receive(:signed_in?).and_return(true)
  end

  describe "GET 'index'" do
    before(:each) do
      queues = AWS::SQS.new.client.stub_for(:list_queues)
      queues[:queue_urls] = ['https://test.url']
    end

    after(:each) do
      AWS::SQS.new.client.stub_for(:list_queues).clear
    end

    it 'returns http success' do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
    it "returns not found when queue doesn't exist" do
      get 'show', id: 'url'
      expect(response).to be_not_found
    end

    context 'when given queue exists' do
      let(:queue) { instance_double('AWS::SQS::Queue', visible_messages: 0, url: 'url') }

      before(:each) do
        queue_info = AWS::SQS.new.client.stub_for(:get_queue_url)
        queue_info[:queue_url] = 'https://test.url'
        allow(AWS::SQS::Queue).to receive(:new).and_return(queue)
      end

      after(:each) do
        AWS::SQS.new.client.stub_for(:get_queue_url).clear
      end

      it 'returns http success' do
        get 'show', id: 'url'
        expect(response).to be_success
        expect(assigns(:queue)).to eq(queue)
      end

      context 'when queue has available messages' do
        it 'reads queue and sets message' do
          allow(queue).to receive(:visible_messages).and_return(1)
          message = double
          expect(queue).to receive(:receive_message).and_return(message)
          get 'show', id: 'url'
          expect(assigns(:message)).to eq(message)
        end
      end

      context 'when queue has no available messages' do
        it 'reads queue and sets message' do
          allow(queue).to receive(:visible_messages).and_return(0)
          get 'show', id: 'url'
          expect(assigns(:message)).to eq(nil)
        end
      end
    end
  end

end
