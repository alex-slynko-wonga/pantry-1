require 'spec_helper'

describe SessionsController do

  describe "#create" do
    before(:each) do
      session[:user_id] = nil
    end

    let(:user_id) { 2 }
    let(:user) { double(id: user_id) }
    let(:auth) { double.as_null_object }

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

end
