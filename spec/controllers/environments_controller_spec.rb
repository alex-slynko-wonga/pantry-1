require 'spec_helper'

describe EnvironmentsController do
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { instance_double('User', role: 'developer', teams: [team]).as_null_object }

  before(:each) do
    allow(@controller).to receive(:current_user).and_return(user)
  end

  describe "GET 'new'" do
    it "should be a success" do
      get :new, team_id: team.id
      expect(response).to be_success
    end
  end

  describe "POST 'create'" do
    it "should create a new environment" do
      expect {
        post :create,
          team_id: team.id,
          environment: {
          name: 'Env 1',
          description: 'Something',
          chef_environment: 'env1',
          environment_type: Environment::TYPES.first
        }
      }.to change { Environment.count }.by(1)
    end

    it "does not redirect if there is a validation error" do
      post :create, team_id: team.id,
                    environment: { environment_type: 'INT' }
      expect(response.status).not_to be eq(302)
    end
  end
end
