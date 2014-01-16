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
      expect(response).to be_success
    end

    it "should assign a server if there is only one team" do
      jenkins_server = FactoryGirl.create(:jenkins_server, team: user.teams.first)
      expect(user.teams.count).to be 1
      get 'index'
      expect(assigns(:jenkins_servers).count).to be 1
    end
  end

  describe "GET 'new'" do
    it "returns http success" do
      get 'new'
      expect(response).to be_success
    end

    describe "when user has no teams without jenkins server" do
      let(:user) { FactoryGirl.create(:user) }

      it "redirects to index page" do
        get 'new'
        expect(response).to be_redirect
      end
      
      it "notifies the user" do
        get 'new'
        expect(flash[:error]).to eq("You cannot create a server because you do not belong to this team")
      end
    end
  end

  describe "POST 'create'" do
    let(:sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', platform_for_ami: 'Lindows') }

    context "when AWSUtility process instance" do
      before(:each) do
        allow(Wonga::Pantry::Ec2Adapter).to receive(:new).and_return(adapter)
        allow(Wonga::Pantry::SQSSender).to receive(:new).and_return(sender)
      end

      it "redirects to resource" do
        post :create, jenkins_server: { team_id: team.id }
        expect(response).to be_redirect
      end
    end

    context "when AWSUtility can't process instance" do
      before(:each) do
        allow_any_instance_of(Wonga::Pantry::AWSUtility).to receive(:request_jenkins_instance).and_return(false)
      end

      it "renders new" do
        post :create, jenkins_server: { team_id: team.id }
        expect(response).to render_template('new')
      end

      it "assigns the teams to the current user" do
        post :create, jenkins_server: { team_id: team.id }
        expect(assigns(:user_teams).size).to be 1
      end
    end
  end
end
