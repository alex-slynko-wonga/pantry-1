require 'spec_helper'

describe AwsCostsController do
  let(:user) { User.new(role: role) }

  before(:each) do
    allow(@controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    before(:each) { get :index }

    context "when user has billing access" do
      let(:role) { 'business_admin' }
      specify { expect(response).to be_success }
    end

    context "when user does not have billing access" do
      let(:role) { 'developer' }
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
      let(:role) { 'business_admin' }

      it "returns an attachment" do
        expect(@controller).to receive(:send_data) do |params|
          @controller.render(text: 'test')
        end
        get :show, id: "some.csv"
      end
    end

    context "when user does not have billing access" do
      let(:role) { 'developer' }
      it "should redirect" do
        expect(@controller).not_to receive(:send_data)
        get :show, id: 'some.csv'
        expect(response).to be_redirect
      end
    end
  end
end
