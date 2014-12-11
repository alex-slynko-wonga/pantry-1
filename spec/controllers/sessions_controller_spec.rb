require 'spec_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#create' do
    before(:each) do
      session[:user_id] = nil
    end

    let(:user_id) { 2 }
    let(:user) { instance_double(User, id: user_id) }
    let(:env) { { 'omniauth.auth' => double.as_null_object } }
    before(:each) do
      allow(subject).to receive(:env).and_return(env)
    end

    it 'creates user record' do
      expect(User).to receive(:from_omniauth).and_return(user)
      post :create
    end

    it 'save user id in session' do
      allow(User).to receive(:from_omniauth).and_return(user)
      post :create
      expect(session[:user_id]).to eq(user_id)
    end

    context 'when contains no info from omniauth' do
      let(:env) { {} }

      it 'redirects back' do
        post :create
        expect(response).to be_redirect
        expect(session[:user_id]).to be_nil
      end
    end

    context "when user can't be created" do
      let(:env) { { 'omniauth.auth' => double.as_null_object } }
      it 'redirects back' do
        allow(User).to receive(:from_omniauth)
        post :create
        expect(response).to be_redirect
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe '#destroy' do
    it 'removes user from session' do
      session[:user_id] = 1
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
  end
end
