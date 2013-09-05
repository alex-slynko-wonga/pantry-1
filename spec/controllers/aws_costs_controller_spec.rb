require 'spec_helper'

describe AwsCostsController do
  let(:user) { instance_double('User') }

  before(:each) do
    @controller.stub(:current_user).and_return(user)
  end

  describe 'GET #index' do
    before(:each) { get :index }

    context "when user has billing access" do
      let(:user) { instance_double('User', 'have_billing_access?' => true) }
      specify { expect(response).to be_success }
    end

    context "when user does not have billing access" do
      let(:user) { instance_double('User', 'have_billing_access?' => false) }
      specify { expect(response).to be_redirect }
    end
  end

  describe 'GET #show' do 
    before(:each) do
      client = AWS::S3::Client.new
      resp = client.stub_for(:get_object)
      resp[:data] = "fake value"
    end

    context "when user has billing access" do
      let(:user) { instance_double('User', 'have_billing_access?' => true) }

      it "returns an attachment" do
        @controller.should_receive(:send_data).and_call_original
        get :show, id: "some.csv"
      end
    end

    context "when user does not have billing access" do
      let(:user) { instance_double('User', 'have_billing_access?' => false) }
      it "should redirect" do
        @controller.should_not_receive(:send_data).and_call_original
        get :show, id: 'some.csv'
        expect(response).to be_redirect
      end
    end
  end
end
