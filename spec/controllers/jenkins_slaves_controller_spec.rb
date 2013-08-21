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
      slave = FactoryGirl.create(:jenkins_slave, jenkins_server: jenkins_server)
      jenkins_server.jenkins_slaves << slave
      get :index, jenkins_server_id: jenkins_server.id, jenkins_slaves: {}
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
      assigns(:slaves).count.should be 1
    end
  end

end
