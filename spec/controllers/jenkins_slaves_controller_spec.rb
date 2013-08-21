require 'spec_helper'

describe JenkinsSlavesController do
  let(:jenkins_server) {FactoryGirl.create(:jenkins_server)}
  let(:user) {FactoryGirl.create(:user)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  	user.teams = [team]
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, jenkins_server_id: jenkins_server.id, jenkins_slaves: {}
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
    end
  end
  
  describe "GET show" do
    it "returns http success" do
      get :show, id: jenkins_server.id
      response.should be_success
    end
  end

end
