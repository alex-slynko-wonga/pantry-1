require 'spec_helper'
require 'json'

describe Aws::Ec2InstancesController do
  let(:ec2_resource)    { instance_double('Wonga::Pantry::Ec2Resource') }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team, state: 'ready') }

  before(:each) do
    session[:user_id] = user.id
    allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
  end

  let(:team) { FactoryGirl.create(:team) }
  let(:environment) { FactoryGirl.create(:environment, team: team) }
  let(:ec2_instance_params) {
    { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                              name: 'InstanceName',
                                              team_id: team.id,
                                              user_id: user.id,
                                              environment_id: environment.id
                                             )}
  }

  describe "#new" do
    it "returns http success" do
      get "new"
      expect(response).to be_success
    end

    it "sets the team if team_id is given" do
      get "new", team_id: team.id
      expect(assigns(:ec2_instance).team_id).to eq(team.id)
    end
  end

  describe "POST 'create'" do
    let(:ec2_instance) { Ec2Instance.new }
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', platform_for_ami: 'Lindows') }

    before(:each) do
      allow(ec2_resource).to receive(:boot)
      allow(Wonga::Pantry::Ec2Adapter).to receive(:new).and_return(adapter)
      allow(Ec2Instance).to receive(:new).and_return(ec2_instance)
    end

    it "uses ec2 adapter to get os" do
      post :create, ec2_instance_params
      expect(adapter).to have_received(:platform_for_ami)
      expect(ec2_instance.platform).to eq('Lindows')
    end

    it "uses ec2_resource to boot" do
      post :create, ec2_instance_params
      expect(ec2_resource).to have_received(:boot)
    end

    context "with custom_ami in params" do
      let(:ec2_instance_params) {
        { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                                   name: 'InstanceName',
                                                   team_id: team.id,
                                                   user_id: user.id,
                                                   environment_id: environment.id
                                                  ),
                                                  custom_ami: custom_ami
        }
      }
      let(:custom_ami) { 'someami' }

      context "when user is authorized to use custom_ami" do
        let(:user) { FactoryGirl.create(:user, team: team, role: 'superadmin') }

        it "sets custom ami" do
          post :create, ec2_instance_params
          expect(ec2_instance.ami).to eq(custom_ami)
        end
      end

      it "skipped" do
        post :create, ec2_instance_params
        expect(ec2_instance.ami).not_to eq(custom_ami)
      end
    end
  end

  context "#show" do
    it "should be success" do
      get :show, id: ec2_instance.id
      expect(response).to be_success
    end
  end

  context "#destroy" do
    before(:each) do
      allow(ec2_resource).to receive(:terminate)
    end

    it "should be success" do
      delete :destroy, id: ec2_instance.id
      expect(response).to be_success
    end

    it "terminates instance if transition acceptable" do
      delete :destroy, id: ec2_instance.id
      expect(ec2_resource).to have_received(:terminate)
    end
  end

  describe "PUT 'update'" do
    let(:ec2_resource)    { instance_double('Wonga::Pantry::Ec2Resource') }

    context "shutting_down" do 
      before(:each) do
        allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
        allow(ec2_resource).to receive(:stop)
      end

      it "initiates shut down using json format" do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'shutdown_now', format: 'json'
        expect(response).to be_success
        expect(ec2_resource).to have_received(:stop)
      end

      it "initiates shut down using html format from instance" do
        request.env['HTTP_REFERER'] = aws_ec2_instance_url(ec2_instance)
        put :update, id: ec2_instance.id, event: 'shutdown_now'
        expect(response).to redirect_to [:aws, ec2_instance]
        expect(ec2_resource).to have_received(:stop)
      end

      it "initiates shut down using html format from slave" do
        request.env['HTTP_REFERER'] = "http://test.host/jenkins_servers/1/jenkins_slaves/1"
        put :update, id: ec2_instance.id, event: 'shutdown_now'
        expect(response).to redirect_to "http://test.host/jenkins_servers/1/jenkins_slaves/1"
        expect(ec2_resource).to have_received(:stop)
      end
    end

    context  "starting" do
      let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team, state: 'shutdown') }
      before(:each) do
        allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
        allow(ec2_resource).to receive(:start)
      end

      it "initiates start using json format" do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'start_instance', format: 'json'
        expect(response).to be_success
        expect(ec2_resource).to have_received(:start)
      end

      it "initiates start using html format" do
        request.env['HTTP_REFERER'] = aws_ec2_instance_url(ec2_instance)
        put :update, id: ec2_instance.id, event: 'start_instance'
        expect(response).to redirect_to [:aws, ec2_instance]
        expect(ec2_resource).to have_received(:start)  
      end

    end
  end
end
