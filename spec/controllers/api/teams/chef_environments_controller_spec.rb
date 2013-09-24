require 'spec_helper'

describe Api::Teams::ChefEnvironmentsController do

  describe "GET 'create'" do

    let(:team) { FactoryGirl.create(:team, chef_environment: nil) }
    let(:params) { {team_id: team.id, chef_environment: {name: 'env_name'}, format: 'json'} }

    context "with valid token" do
      before(:each) do
        request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
      end

      it "saves chef_environment" do
        post 'create', params
        expect(team.reload.chef_environment).to eq('env_name')
      end

      it "returns http success" do
        team.stub(:update_attributes).with(chef_environment: 'env_name')
        post 'create', params
        expect(response.status).to eq 201
      end
    end

    context "without token" do
      it "returns 404" do
        post 'create', params
        expect(response.status).to eq 404
      end
    end
  end

end
