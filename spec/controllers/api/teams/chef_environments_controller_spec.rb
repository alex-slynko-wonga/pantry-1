require 'spec_helper'

describe Api::Teams::ChefEnvironmentsController do

  describe "PUT 'update'" do

    let(:environment) { FactoryGirl.create(:environment, chef_environment: nil) }
    let(:params) { {team_id: environment.team_id, id: environment.id, chef_environment: 'env_name', format: 'json'} }

    context "with valid token" do
      before(:each) do
        request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
      end

      it "saves chef_environment" do
        put 'update', params
        expect(environment.reload.chef_environment).to eq('env_name')
      end

      it "returns http success" do
        put 'update', params
        expect(response.status).to eq 204
      end
    end

    context "without token" do
      it "returns 404" do
        put 'update', params
        expect(response.status).to eq 404
      end
    end
  end
end
