require 'spec_helper'

RSpec.describe 'Admin::MaintenanceWindows', type: :request do
  describe 'GET /admin_maintenance_windows' do
    context 'as anonymous user' do
      it "redirects to '/auth/ldap'" do
        get admin_maintenance_windows_url
        expect(response).to redirect_to('/auth/ldap')
      end
    end
    #    context "as logged-in developer" do
    #      let(:user) { FactoryGirl.create(:user, role: "developer",) }
    #      it "returns 401" do
    #        session[:user_id] = user.id
    #        get admin_maintenance_windows_url
    #        expect(response.status).to be(401)
    #      end
    #    end
    #    context "as logged-in superadmin" do
    #      let(:user) { FactoryGirl.create(:user, role: "superadmin",) }
    #      it "returns 200" do
    #        session[:user_id] = user.id
    #        get admin_maintenance_windows_url
    #        expect(response.status).to be(200)
    #      end
    #    end
  end
end
