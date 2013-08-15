require 'spec_helper'

describe JenkinsServersController do
  let(:user) {FactoryGirl.create(:user)}
  let(:single_team) {FactoryGirl.create(:team)}

  before(:each) do
	session[:user_id] = user.id
	user.teams = [single_team]
  end

  describe "GET 'new'" do
	it "returns http success" do
	  get 'new'
	  response.should be_success
	end
  end

  describe "GET 'create'" do
    it "returns http success" do
      get 'create'
      response.should be_success
    end
  end
end
