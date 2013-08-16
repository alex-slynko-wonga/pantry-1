require 'spec_helper'

describe JenkinsServersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
	session[:user_id] = user.id
	user.teams = [team]

	AWS.stub!
  end

  describe "GET 'new'" do
	it "returns http success" do
	  get 'new'
	  response.should be_success
	end
  end

  describe "POST 'create'" do
	it "creates new resource, sends message to AWS and redirects to resource" do
		client = AWS::SQS.new.client
		resp = client.stub_for(:get_queue_url)
		resp[:queue_url] = "some_url"
		
		client.should_receive(:send_message) do |msg|
			JSON.parse(msg[:message_body])
			AWS::Core::Response.new
		end

		post 'create', {"jenkins_server" => {"team_id" => team.id}}
		response.should be_redirect
	end
  end
end
