require 'spec_helper'

describe JenkinsServersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  	user.teams = [team]
  end
  
  describe "index" do
  	it "returns http success" do
  	  get 'index'
  	  response.should be_success
  	end
    
    it "should assign a server if there is only one team" do
      FactoryGirl.create(:jenkins_server)
      get 'index'
      assigns(:jenkins_servers).count.should be 1
    end
    
    it "should not assign a server if threre are two teams" do
      jenkins_server = FactoryGirl.create(:jenkins_server)
      user.teams << FactoryGirl.create(:team) # we have two teams
      user.teams << jenkins_server.team
      get 'index', team_id: nil
      assigns(:jenkins_servers).should be_nil
    end
  end

  describe "GET 'new'" do
  	it "returns http success" do
  	  get 'new'
  	  response.should be_success
  	end
  end
  
  describe "POST 'create'" do
    it "creates new resource, sends message to AWS and redirects to resource" do
      Wonga::Pantry::SQSSender.any_instance.stub(:send_message)
      post :create, jenkins_server: { team_id: team.id }
      response.should be_redirect
  	end
  
    it "renders new if JenkinsServer was not saved" do
      JenkinsServer.any_instance.stub(:persisted?).and_return(false)
    
      post :create, jenkins_server: { team_id: team.id }
      response.should render_template('new')
    end
  
    it "assigns the teams to the current user if JenkinsServer was not saved" do
      JenkinsServer.any_instance.stub(:persisted?).and_return(false)
    
      post :create, jenkins_server: { team_id: team.id }
      assigns(:user_teams).size.should be 1
    end
	end
end