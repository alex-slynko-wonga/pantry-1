require 'spec_helper'

describe AwsCostsController do
  describe 'GET #index' do 
    it "returns http success with a html request" do
      get 'index'
      response.should be_success
    end  
  end

  describe 'GET #show' do 
    it "returns an attachment" do 
      client = AWS::S3::Client.new
      resp = client.stub_for(:get_object)
      resp[:data] = "fake value"

      @controller.should_receive(:send_data).and_call_original
      get :show, id: "some.csv"
    end
  end    
end
