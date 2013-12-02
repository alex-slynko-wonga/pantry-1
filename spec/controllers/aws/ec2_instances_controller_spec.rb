require 'spec_helper'
require 'json'

describe Aws::Ec2InstancesController do
  let(:user) { FactoryGirl.create(:user, team: team) }
  before(:each) do
    session[:user_id] = user.id
  end

  let(:team) { FactoryGirl.create(:team) }
  let(:ec2_instance_params) {
    { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                              name: 'InstanceName',
                                              team_id: team.id,
                                              user_id: user.id
                                             )}
  }

  describe "#new" do
    it "returns http success" do
      get "new"
      response.should be_success
    end

    it "sets the team if team_id is given" do
      get "new", team_id: team.id
      assigns(:ec2_instance).team_id.should == team.id
    end
  end

  describe "POST 'create'" do
    let(:ec2_instance) { Ec2Instance.last }
    let(:sender) { instance_double('Wonga::Pantry::SQSSender').as_null_object }
    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', platform_for_ami: 'Lindows') }

    before(:each) do
      Wonga::Pantry::Ec2Adapter.stub(:new).and_return(adapter)
      Wonga::Pantry::SQSSender.stub(:new).and_return(sender)
    end

    it "creates an ec2 instance request record" do
      expect{ post :create, ec2_instance_params}.to change(Ec2Instance, :count).by(1)
      expect(ec2_instance).to_not be_booted
    end

    it "sends message using SQSSender" do
      post :create, ec2_instance_params
      expect(sender).to have_received(:send_message)
    end

    it "uses ec2 adapter to get os" do
      post :create, ec2_instance_params
      expect(adapter).to have_received(:platform_for_ami)
      expect(ec2_instance.platform).to eq('Lindows')
    end
  end

  context "#show" do
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }
    it "should be success" do
      get :show, id: ec2_instance.id
      expect(response).to be_success
    end
  end

  context "#destroy" do
    let(:terminator) { instance_double('Wonga::Pantry::Ec2Terminator') }

    before(:each) do
      Wonga::Pantry::Ec2Terminator.stub(:new).and_return(terminator)
      terminator.stub(:terminate)
    end

    let(:ec2_instance_running) { FactoryGirl.create(:ec2_instance, :running, team: team) }
    let(:ec2_instance_terminated) { FactoryGirl.create(:ec2_instance, :terminated, team: team) }

    it "should be success" do
      delete :destroy, id: ec2_instance_running.id
      expect(response).to be_success
    end

    it "terminates instance if transition acceptable" do
      delete :destroy, id: ec2_instance_running.id
      expect(terminator).to have_received(:terminate).with(user)
    end

    it "shows an error message if transition unacceptable" do
      delete :destroy, id: ec2_instance_terminated.id 
      expect(terminator).not_to have_received(:terminate).with(user)

    end
  end
  
  describe "PUT 'update'" do
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource') }

    context "shutting_down" do 
      let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team, state: "ready") }

      before(:each) do
        Wonga::Pantry::Ec2Resource.stub(:new).and_return(ec2_resource)
        ec2_resource.stub(:stop)
      end

      it "initiates shut down using json format" do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'shutdown_now', format: 'json'
        response.should be_success
        JSON.parse(response.body)["state"].should eq("shutting_down")
        ec2_instance.reload.state.should eq("shutting_down")
        expect(ec2_resource).to have_received(:stop)
      end
      
      it "initiates shut down using html format" do
        put :update, id: ec2_instance.id, event: 'shutdown_now'
        response.should redirect_to [:aws, ec2_instance]
        ec2_instance.reload.state.should eq("shutting_down")
        expect(ec2_resource).to have_received(:stop)  
      end
    end

    context  "starting" do
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team, state: "shutdown") }

      before(:each) do
        Wonga::Pantry::Ec2Resource.stub(:new).and_return(ec2_resource)
        ec2_resource.stub(:start)
      end

      it "initiates start using json format" do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'start_instance', format: 'json'
        response.should be_success
        JSON.parse(response.body)["state"].should eq("starting")
        ec2_instance.reload.state.should eq("starting")
        expect(ec2_resource).to have_received(:start)
      end
      
      it "initiates start using html format" do
        put :update, id: ec2_instance.id, event: 'start_instance'
        response.should redirect_to [:aws, ec2_instance]
        ec2_instance.reload.state.should eq("starting")
        expect(ec2_resource).to have_received(:start)  
      end

    end
  end
end
