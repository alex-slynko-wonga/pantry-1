require 'spec_helper'

describe Api::Ec2InstancesController do
  describe "#create" do
    let(:team) { FactoryGirl.build(:team) }
    let(:user) { FactoryGirl.build(:user, team: team) }

    context "with valid token" do
      before(:each) do
        request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
        @ec2_instance = instance_double('Ec2Instance', id: 45)
        @ec2_instance.stub(:user).and_return(user)
        Ec2Instance.stub(:find).with('45').and_return(@ec2_instance)
        @state = instance_double('Wonga::Pantry::Ec2InstanceState')
        Wonga::Pantry::Ec2InstanceState.stub(:new).and_return(@state)
        @user = instance_double('User', id: 1)
        User.stub(:find).with(1).and_return(@user)
      end

      it "updates an instance" do
        @state.should_receive(:change_state)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
      end

      it "returns http success" do
        @state.stub(:change_state)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json', test: false
        response.should be_success
      end
    end
  end
end
