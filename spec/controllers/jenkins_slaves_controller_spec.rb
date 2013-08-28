require 'spec_helper'

describe JenkinsSlavesController do
  let(:jenkins_server) {FactoryGirl.create(:jenkins_server, team: team)}
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
    it "request jenkins instance using AWSUtility" do
      expect_any_instance_of(Wonga::Pantry::AWSUtility).to receive(:request_jenkins_instance) do |arguments, slave|
        expect(slave.jenkins_server_id).to eq jenkins_server.id
        false
      end
      post :create, jenkins_server_id: jenkins_server.id
    end

    context "on success" do
      before(:each) do
        Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(true)
      end

      it "redirects" do
        JenkinsSlave.any_instance.stub(:id).and_return(42)
        post :create, jenkins_server_id: jenkins_server.id
        response.should be_redirect
      end
    end

    context "when AWSUtility can't process instance" do
      before(:each) do
        Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(false)
      end

      it "renders new" do
        post :create, jenkins_server_id: jenkins_server.id
        response.should render_template('new')
      end

      it "assigns the teams to the current user" do
        post :create, jenkins_server_id: jenkins_server.id
        assigns(:user_teams).size.should be 1
      end
    end
  end
end
