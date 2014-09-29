require 'spec_helper'

describe TeamsController do
  let(:chef_utility) { instance_double('Wonga::Pantry::ChefUtility').as_null_object }
  let(:team) { FactoryGirl.create(:team) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team_params) { {team: FactoryGirl.attributes_for(:team, name: 'TeamName', product: 'TeamProduct', region: 'TeamRegion', description: 'TeamDescription')} }
  let(:user_params) { { users: [username, "Test User"] } }
  let(:username) { 'test.user' }

  describe "POST 'create'" do
    let(:team) { Team.last }

    before :each do 
      allow(Wonga::Pantry::ChefUtility).to receive(:new).and_return(chef_utility)
    end

    it "returns http success" do
      post 'create', team_params.merge(users: [user.username, user.name])
      expect(response).to be_redirect
    end

    it "creates a team" do
      expect{ post :create, team_params.merge(users: [user.username, user.name]) }.to change(Team, :count).by(1)
      expect(assigns(:team).name).to eq('TeamName')
      expect(assigns(:team).product).to eq('TeamProduct')
      expect(assigns(:team).region).to eq('TeamRegion')
      expect(assigns(:team).description).to eq('TeamDescription')
    end

    it "creates a team without selecting a user" do
      session[:user_id] = FactoryGirl.create(:user).id
      expect{ post :create, team_params }.to change(Team, :count).by(1)
      expect(team.users.count).to eq(1)
    end

    it "creates user and add him to team" do
      expect { post :create, team_params.merge(user_params) }.to change(User, :count).by(1)
      expect(team.users.count).to eq(1)
      expect(team.users.first.username).to eq(username)
    end

    it "finds user by its username and adds it to team" do
      user = User.create(username: username)
      expect { post :create, team_params.merge(user_params) }.to_not change(User, :count)
      expect(team.users.count).to eq(1)
      expect(team.users.first).to eq(user)
    end

    it "sends SQS message to chef env create daemon" do
      post :create, team_params.merge(users: [user.username, user.name])
      expect(chef_utility).to have_received(:request_chef_environment)
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      # make sure current_user is the stubbed user and is part of team to grant permission
      session[:user_id] = user.id
    end

    it "returns http success" do
      put 'update', team_params.merge({id: team.id})
      expect(response).to be_redirect
    end

    it "should update a team" do 
      put 'update', team_params.merge({id: team.id})
      team.reload.name
      expect(team.name).to eq('TeamName')
      team.reload.product
      expect(team.product).to eq('TeamProduct')
      team.reload.region
      expect(team.region).to eq('TeamRegion')
    end

    it "finds user by its username and adds it to team" do
      expect{put 'update', team_params.merge({id: team.id}).merge(user_params)}.to change(User, :count)
      expect(team.users.size).to eq(1)
      expect(team.users.first.username).to eq(username)
    end

    it "finds user by its username and adds it to team" do
      user = FactoryGirl.create(:user, username: username)
      expect { put :update, team_params.merge({id: team.id}).merge(user_params) }.to_not change(User, :count)
      expect(team.users.size).to eq(1)
      expect(team.users.first).to eq(user)
    end

    it "removes users from team if they were not in params" do
      team.users << User.create(username: username)
      put 'update', team_params.merge({id: team.id})
      expect(team.users.count).to eq(1)
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      expect(response).to be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      session[:user_id] = user.id
      get 'show', :id => team.id
      expect(response).to be_success
    end
  end

  describe "POST 'deactivate'" do
    let(:user) { FactoryGirl.create(:superadmin) }
    context "when confirmed" do
      it "deactivates team" do
        session[:user_id] = user.id
        post 'deactivate', id: team.id, confirm: team.name
        expect(team.reload).to be_disabled
      end
    end

    context "without confirmation" do
      it "does nothing" do
        session[:user_id] = user.id
        post 'deactivate', id: team.id
        expect(team.reload).not_to be_disabled
      end
    end
  end
end
