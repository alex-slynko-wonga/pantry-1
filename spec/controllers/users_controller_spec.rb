require 'spec_helper'

describe UsersController do
  let (:user) { FactoryGirl.create(:user) }

  describe "GET #index" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get 'show', :id => user.id
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    context "when current_user can edit other users" do
      before(:each) do
        allow(controller).to receive(:authorize)
      end

      it "returns http success" do
        get "edit", id: user.id
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "when current_user can edit other users" do
      before(:each) do
        allow(controller).to receive(:authorize)
      end

      it "redirects" do
        put 'update', { id: user.id, user: { role: 'team_admin' } }
        expect(response).to be_redirect
      end

      it "updates users role" do 
        put 'update', { id: user.id, user: { role: 'team_admin' } }
        expect(user.reload.role).to eq('team_admin')
      end

    end
  end
end
