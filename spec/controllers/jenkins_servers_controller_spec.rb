require 'spec_helper'

describe JenkinsServersController do
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team) }

  before(:each) do
    session[:user_id] = user.id
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

    describe "when user has no teams without jenkins server" do
      let(:user) { FactoryGirl.create(:user) }

      it "redirects to index page" do
        get 'new'
        expect(response).to be_redirect
      end
      
      it "notifies the user" do
        get 'new'
        flash[:error].should eq("You cannot create a server because you do not belong to this team")
      end
    end
  end

  describe "POST 'create'" do
    let(:sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', platform_for_ami: 'Lindows') }

    context "when AWSUtility process instance" do
      before(:each) do
        Wonga::Pantry::Ec2Adapter.stub(:new).and_return(adapter)
        Wonga::Pantry::SQSSender.stub(:new).and_return(sender)
      end

      it "redirects to resource" do
        post :create, jenkins_server: { team_id: team.id }
        response.should be_redirect
      end
    end

    context "when AWSUtility can't process instance" do
      before(:each) do
        Wonga::Pantry::AWSUtility.any_instance.stub(:request_jenkins_instance).and_return(false)
      end

      it "renders new" do
        post :create, jenkins_server: { team_id: team.id }
        response.should render_template('new')
      end

      it "assigns the teams to the current user" do
        post :create, jenkins_server: { team_id: team.id }
        assigns(:user_teams).size.should be 1
      end
    end
  end
end
