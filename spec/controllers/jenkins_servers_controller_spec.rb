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
	it "creates new resource and redirects to it" do
		post 'create', {"jenkins_server" => {"team_id" => team.id}}
		response.should be_redirect
	end
  end
end
