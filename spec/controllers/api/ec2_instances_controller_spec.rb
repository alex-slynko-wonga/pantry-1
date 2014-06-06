require 'spec_helper'

describe Api::Ec2InstancesController do
  describe "#update" do
    let(:team) { FactoryGirl.build(:team) }
    let(:user) { FactoryGirl.build(:user, team: team) }

    context "with valid token" do
      before(:each) do
        request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
        @ec2_instance = instance_double('Ec2Instance', id: 45)
        allow(@ec2_instance).to receive(:user).and_return(user)
        allow(Ec2Instance).to receive(:find).with('45').and_return(@ec2_instance)
        @state = instance_double('Wonga::Pantry::Ec2InstanceState')
        allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
        @user = instance_double('User', id: 1)
        allow(User).to receive(:find).with(1).and_return(@user)
      end

      it "updates an instance" do
        expect(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
      end

      it "returns http success" do
        allow(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json', test: false
        expect(response).to be_success
      end
    end
  end
end
