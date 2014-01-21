require 'spec_helper'

describe Api::ChefNodesController do
  let(:team) { FactoryGirl.build(:team) }
  let(:user) { FactoryGirl.build(:user, team: team) }

  before(:each) do
    request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
    @ec2_instance = instance_double('Ec2Instance', id: 1)
    allow(@ec2_instance).to receive(:user).and_return(user)
    allow(Ec2Instance).to receive(:find).with("1").and_return(@ec2_instance)
    @state = instance_double('Wonga::Pantry::Ec2InstanceState')
    allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
    @user = instance_double("User", id: 1)
    allow(User).to receive(:find).with(1).and_return(@user)
  end

  describe "DELETE 'destroy'" do
    it "calls change_state" do
      expect(@state).to receive(:change_state).and_return(true)
      delete :destroy, id: 1, user_id: 1, format: 'json'
    end

    it "returns 204 status code" do
      allow(@state).to receive(:change_state).and_return(true)
      delete :destroy, id: 1, user_id: 1, format: 'json'
      expect(response.code).to match /204/
    end
  end
end
