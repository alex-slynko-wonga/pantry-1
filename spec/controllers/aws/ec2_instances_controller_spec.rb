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

    let(:ec2_instance) { FactoryGirl.create(:ec2_instance, team: team) }

    it "should be success" do
      delete :destroy, id: ec2_instance.id
      expect(response).to be_success
    end

    it "terminates instance" do
      delete :destroy, id: ec2_instance.id
      expect(terminator).to have_received(:terminate).with(user)
    end
  end
end
