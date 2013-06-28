require 'spec_helper'

describe SessionsController do

<<<<<<< HEAD
  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end

  describe "GET 'failure'" do
    it "returns http success" do
      get 'failure'
      response.should be_success
    end
  end

=======
  describe "#create" do
    before(:each) do
      session[:user_id] = nil
    end

    let(:user_id) { 2 }
    let(:user) { double(id: user_id) }
    let(:auth) { 'test' }

    it "creates user record" do
      expect(User).to receive(:from_omniauth).and_return(user)
      subject.stub(:env).and_return({'omniauth.auth' => auth})
      post :create
    end

    it "save user id in session" do
      User.stub(:from_omniauth).and_return(user)
      subject.stub(:env).and_return({'omniauth.auth' => auth})
      post :create
      expect(session[:user_id]).to eq(user_id)
    end
  end

  describe "#destroy" do
    it "removes user from session" do
      session[:user_id] = 1
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
  end
>>>>>>> c205508d1f8a484555f20e06c9af0b631d54145a
end
