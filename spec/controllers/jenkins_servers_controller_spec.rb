require 'spec_helper'

describe JenkinsServersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  	user.teams << team
  end
  
  describe "index" do
  	it "returns http success" do
  	  get 'index'
  	  response.should be_success
  	end
    
    it "should assign a server if there is only one team" do
      jenkins_server = FactoryGirl.create(:jenkins_server, team: user.teams.first)
      user.teams.count.should be 1
      get 'index'
      assigns(:jenkins_servers).count.should be 1
    end
  end

  describe "GET 'new'" do
  	it "returns http success" do
  	  get 'new'
  	  response.should be_success
  	end
  end
  
  describe "POST 'create'" do
    before(:each) do
      client = AWS::SQS.new.client
      resp = client.stub_for(:get_queue_url)
      resp[:queue_url] = "some_url"

      client.stub(:send_message) do |msg|
        JSON.parse(msg[:message_body])
        AWS::Core::Response.new
      end
    end
    
    it "creates new resource, sends message to AWS and redirects to resource" do
      Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(true)
      
      post :create, jenkins_server: { team_id: team.id }
      response.should be_redirect
  	end
  
    it "renders new if JenkinsServer was not saved" do
      Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(false)
      
      post :create, jenkins_server: { team_id: team.id }
      response.should render_template('new')
    end
  
    it "assigns the teams to the current user if JenkinsServer was not saved" do
      Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(false)
      
      post :create, jenkins_server: { team_id: team.id }
      assigns(:user_teams).size.should be 1
    end
	end
end