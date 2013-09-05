require 'spec_helper'

describe AwsCostsController do
  let(:user) { User.new(email: email) }
  let(:email) { 'some_person@example.com' }
  before(:each) do
    @controller.stub(:current_user).and_return(user)
  end

  describe 'GET #index' do
    before(:each) { get :index }

    context "when user is jonathan" do
      let(:email) { 'jonathan.galore@example.com' }
      specify { expect(response).to be_success }
    end

    context "when user is not jonathan" do
      specify { expect(response).to be_redirect }
    end
  end

  describe 'GET #show' do 
    context "when user is jonathan" do
      let(:email) { 'jonathan.galore@example.com' }

      it "returns an attachment" do
        client = AWS::S3::Client.new
        resp = client.stub_for(:get_object)
        resp[:data] = "fake value"

        @controller.should_receive(:send_data).and_call_original
        get :show, id: "some.csv"
      end
    end

    context "when user is not jonathan" do
      it "should redirect" do
        client = AWS::S3::Client.new
        resp = client.stub_for(:get_object)
        resp[:data] = "fake value"

        get :show, id: 'some.csv'
        expect(response).to be_redirect
      end
    end
  end
end
