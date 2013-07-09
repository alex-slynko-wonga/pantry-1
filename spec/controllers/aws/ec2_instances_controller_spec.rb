require 'spec_helper'

describe Aws::Ec2InstancesController do
  let(:instance) { FactoryGirl.create(:ec2_instance)}
  let(:instance_params) { {team: FactoryGirl.attributes_for(:ec2_instance, 
    name: 'InstanceName', 
    instance_id: 'Pending',
    status: "Pending"
  )} }

  describe "#new" do
    it "returns http success" do
      get "new"
      response.should be_success
    end
  end

  describe  "POST 'create'" do
    it "creates a team" do
      expect{ post :create, instance_params}.to change(Ec2Instance, :count).by(1)
      instance.name.should == 'TeamName'
    end
  end
end
