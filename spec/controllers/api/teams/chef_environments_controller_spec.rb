require 'spec_helper'

describe Api::Teams::ChefEnvironmentsController do

  describe "GET 'create'" do
    
    let(:team) { mock_model('Team', id: 1, chef_environment: 'env_name') }
    let(:params) { {team_id: 1, chef_environment: 'env_name', format: 'json'} }
    
    context "with valid token" do
      before(:each) do
        request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
        Team.stub(:find).with("1").and_return(team)
      end
      
      it "saves chef_environment" do
        team.should_receive(:update_attributes).with(chef_environment: 'env_name')
        get 'create', params
      end
      
      it "returns http success" do
        team.stub(:update_attributes).with(chef_environment: 'env_name')
        get 'create', params
        expect(response.status).to eq 200
      end
    end
    
    context "without token" do
      it "returns 404" do
        team.as_null_object
        get 'create', params
        expect(response.status).to eq 404
      end
    end
  end

end
