require 'spec_helper'

describe Aws::Ec2InstancesController do
  let(:user) { FactoryGirl.create(:user) }
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
      ec2_instance.reload
      ec2_instance.name.should == 'InstanceName'
      ec2_instance.booted.should == 'pending'
    end
  end
end
