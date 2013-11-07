require 'spec_helper'

describe QueuesController do

  describe "GET 'index'" do
    before(:each) do
      queues = AWS::SQS.new.client.stub_for(:list_queues)
      queues[:queue_urls] = ['https://test.url']
    end

    after(:each) do
      AWS::SQS.new.client.stub_for(:list_queues).clear
    end

    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns not found when queue doesn't exist" do
      get 'show', id: 'url'
      response.should be_not_found
    end

    context "when given queue exists" do
      let(:queue) { instance_double('AWS::SQS::Queue').as_null_object }

      before(:each) do
        queue_info = AWS::SQS.new.client.stub_for(:get_queue_url)
        queue_info[:queue_url] = 'https://test.url'
        AWS::SQS::Queue.stub(:new).and_return(queue)
      end

      after(:each) do
        AWS::SQS.new.client.stub_for(:get_queue_url).clear
      end

      it "returns http success" do
        get 'show', id: 'url'
        expect(response).to be_success
        expect(assigns(:queue)).to eq(queue)
      end

      context "when queue has available messages" do
        it "reads queue and sets message" do
          queue.stub(:visible_messages).and_return(1)
          message = double
          expect(queue).to receive(:receive_message).and_return(message)
          get 'show', id: 'url'
          expect(assigns(:message)).to eq(message)
        end
      end

      context "when queue has no available messages" do
        it "reads queue and sets message" do
          queue.stub(:visible_messages).and_return(0)
          get 'show', id: 'url'
          expect(assigns(:message)).to eq(nil)
          expect(queue).to_not have_received(:receive_message)
        end
      end
    end
  end

end
