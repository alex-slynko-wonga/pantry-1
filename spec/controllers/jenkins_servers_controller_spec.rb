require 'spec_helper'

describe JenkinsServersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  	user.teams = [team]
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
      resp[:queue_url] = "https://sqs.eu-west-1.amazonaws.com/000000000000/blop"
      sqs_sender = Wonga::Pantry::SQSSender.new()
      @aws_utility = Wonga::Pantry::AWSUtility.new(sqs_sender)
    end
    
    it "creates new resource, sends message to AWS and redirects to resource" do
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