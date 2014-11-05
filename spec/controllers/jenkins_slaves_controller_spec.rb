require 'spec_helper'

RSpec.describe JenkinsSlavesController, type: :controller do
  let(:jenkins_server) { FactoryGirl.create(:jenkins_server, :running, team: team) }
  let(:jenkins_slave) { FactoryGirl.create(:jenkins_slave, jenkins_server: jenkins_server) }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:team) { FactoryGirl.create(:team) }
  let(:ec2_instance_state) { instance_double('Wonga::Pantry::Ec2InstanceState', change_state: true) }

  before(:each) do
    session[:user_id] = user.id
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index, jenkins_server_id: jenkins_server.id
      expect(response).to be_success
      expect(assigns(:jenkins_server).id).to be jenkins_server.id
    end
  end

  describe "GET 'show'" do
    it 'returns http success' do
      get :show, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
      expect(response).to be_success
      expect(assigns(:jenkins_server).id).to be jenkins_server.id
      expect(assigns(:ec2_instance).id).to be jenkins_slave.ec2_instance.id
    end
  end

  describe "GET 'new'" do
    it 'returns http success' do
      get :new, jenkins_server_id: jenkins_server.id
      expect(response).to be_success
      expect(assigns(:jenkins_server).id).to be jenkins_server.id
      expect(assigns(:jenkins_slave)).not_to be_nil
    end
  end

  describe "POST 'create'" do
    let(:jenkins) { JenkinsSlave.new(jenkins_server_id: jenkins_server.id, id: 42) }
    let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility) }

    before(:each) do
      allow(Wonga::Pantry::JenkinsUtility).to receive(:new).and_return(jenkins_utility)
      allow(JenkinsSlave).to receive(:new).and_return(jenkins_slave)
    end

    it 'request jenkins instance using JenkinsUtility' do
      expect(jenkins_utility).to receive(:request_jenkins_instance) do |_arguments, slave|
        expect(slave.jenkins_server_id).to eq jenkins_server.id
        false
      end
      post :create, jenkins_server_id: jenkins_server.id, jenkins_slave: { instance_role_id: 1 }
    end

    context 'on success' do
      let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility, request_jenkins_instance: true) }
      it 'redirects' do
        post :create, jenkins_server_id: jenkins_server.id, jenkins_slave: { instance_role_id: 1 }
        expect(response).to be_redirect
      end
    end

    context "when JenkinsUtility can't process instance" do
      let(:jenkins_utility) { instance_double(Wonga::Pantry::JenkinsUtility, request_jenkins_instance: false) }

      it 'renders new' do
        post :create, jenkins_server_id: jenkins_server.id, jenkins_slave: { instance_role_id: 1 }
        expect(response).to render_template('new')
      end
    end
  end

  describe "DELETE 'destroy'" do
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource') }

    before(:each) do
      allow(Wonga::Pantry::Ec2Resource).to receive(:new).with(jenkins_slave.ec2_instance, user).and_return(ec2_resource)
      allow(ec2_resource).to receive(:terminate)
    end

    it 'find the jenkins slave' do
      delete :destroy, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
      expect(assigns(:jenkins_slave)).to be_truthy
    end

    it 'should redirect to the list of slaves' do
      delete :destroy, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
      expect(response).to redirect_to jenkins_server_jenkins_slaves_url(jenkins_server)
    end

    it 'calls Ec2Resource to terminate jenkins slave' do
      expect(ec2_resource).to receive(:terminate)
      delete :destroy, jenkins_server_id: jenkins_server.id, id: jenkins_slave.id
    end
  end
end
