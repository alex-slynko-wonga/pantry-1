require 'spec_helper'

describe JenkinsSlavesController do
  let(:jenkins_server) {FactoryGirl.create(:jenkins_server)}
  let(:jenkins_slave) {FactoryGirl.create(:jenkins_slave, jenkins_server: jenkins_server)}
  let(:user) {FactoryGirl.create(:user, team: team)}
  let(:team) {FactoryGirl.create(:team)}

  before(:each) do
  	session[:user_id] = user.id
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index, jenkins_server_id: jenkins_server.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
    end
  end
  
  describe "GET 'show'" do
    it "returns http success" do
      get :show, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
      assigns(:ec2_instance).id.should be jenkins_slave.ec2_instance.id
    end
  end
  
  describe "GET 'new'" do
    it "returns http success" do
      get :new, jenkins_server_id: jenkins_server.id
      response.should be_success
      assigns(:jenkins_server).id.should be jenkins_server.id
      assigns(:jenkins_slave).should_not be_nil
    end
  end
  
  describe "POST 'create'" do
  	it "creates new resource, sends message to AWS and redirects to resource" do
  	end
  end

end
