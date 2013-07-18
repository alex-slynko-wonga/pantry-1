require 'spec_helper'
require 'json'

describe Aws::Ec2InstancesController do
  let(:user) { FactoryGirl.create(:user) }
  before(:each) do 
    session[:user_id] = user.id
  end
  let(:team) { FactoryGirl.create(:team) }
  let(:ec2_instance_params) { 
    {ec2_instance: FactoryGirl.attributes_for(:ec2_instance, 
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
  end

  describe "POST 'create'" do
    let (:ec2_instance) { Ec2Instance.last }
    it "creates an ec2 instance request record" do
      expect{ post :create, ec2_instance_params}.to change(Ec2Instance, :count).by(1)
      ec2_instance.name.should == 'InstanceName'
      ec2_instance.booted.should == false
    end
  end
  
  describe "PUT 'update'" do
    before :each do
      @ec2_instance = FactoryGirl.create(:ec2_instance)
    end
  
    it "updates booted field" do
      @incoming_params = { id: @ec2_instance.id, booted: true, format: :json }
      put :update, @incoming_params
      response.should be_success
      @ec2_instance.reload
      @ec2_instance.booted.should be_true
    end
    
    it "updates bootstrapped field" do
      @incoming_params = { id: @ec2_instance.id, bootstrapped: true, format: :json }
      put :update, @incoming_params
      response.should be_success
      @ec2_instance.reload
      @ec2_instance.bootstrapped.should be_true
    end
    
    it "updates joined field" do
      @incoming_params = { id: @ec2_instance.id, joined: true, format: :json }
      put :update, @incoming_params
      response.should be_success
      @ec2_instance.reload
      @ec2_instance.joined.should be_true
    end
    
  end

  context "#show" do
    let(:ec2_instance) { FactoryGirl.create(:ec2_instance) }
    it "should be success" do
      get :show, id: ec2_instance.id
    end
  end
end
