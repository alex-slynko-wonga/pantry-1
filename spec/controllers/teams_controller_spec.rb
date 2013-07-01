require 'spec_helper'

describe TeamsController do
  let (:team) { FactoryGirl.create(:team) }
  let(:team_params) { {team: FactoryGirl.attributes_for(:team, name: 'TeamName', description: 'TeamDescription')} }
    
  describe "POST 'create'" do
    it "returns http success" do
      post 'create', team_params
      response.should be_redirect
    end
    
    it "creates a team" do
      expect{ post :create, team_params}.to change(Team, :count).by(1)
      team = Team.last
      team.name.should == 'TeamName'
      team.description.should == 'TeamDescription'
    end
  end

  describe "PUT 'update'" do 
    it "returns http success" do 
      put 'update', team_params.merge({id: team.id})
      response.should be_redirect
    end

    it "should update a team" do 
      put 'update', team_params.merge({id: team.id})
      team = Team.last
      team.name.should == 'TeamName'
    end
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', :id => team.id
      response.should be_success
    end
  end

=begin
  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end
=end

end
