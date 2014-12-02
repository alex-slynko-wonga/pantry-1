require 'spec_helper'

RSpec.describe Api::Ec2InstancesController, type: :controller do
  describe '#update' do
    let(:team) { FactoryGirl.build(:team) }
    let(:user) { FactoryGirl.build(:user, team: team) }
    let(:token) { SecureRandom.uuid }

    context 'with valid token' do
      before(:each) do
        request.headers['X-Auth-Token'] = token
        @ec2_instance = instance_double('Ec2Instance', id: 45)
        allow(@ec2_instance).to receive(:user).and_return(user)
        allow(Ec2Instance).to receive(:find).with('45').and_return(@ec2_instance)
        @state = instance_double('Wonga::Pantry::Ec2InstanceState')
        allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
        @user = instance_double('User', id: 1)
        allow(User).to receive(:find).with(1).and_return(@user)
        FactoryGirl.create(:api_key, key: token, permissions: %w(api_ec2_instance))
      end

      it 'updates an instance' do
        expect(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
      end

      it 'returns http success' do
        allow(@state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json', test: false
        expect(response).to be_success
      end
    end
  end

  describe '#update_info_from_aws' do
    let(:token) { SecureRandom.uuid }
    let(:ec2_instance) { instance_double(Ec2Instance, update_info: true, id: 45) }

    context 'for instance with some id' do
      before(:each) do
        request.headers['X-Auth-Token'] = token
        allow(Ec2Instance).to receive(:find).with('45').and_return(ec2_instance)
      end

      it 'returns http success' do
        FactoryGirl.create(:api_key, key: token, permissions: %w(update_info_from_aws_api_ec2_instance))
        post :update_info_from_aws, id: 45, format: 'json'
        expect(response).to be_success
      end

      it 'forbid access for api_ec2_instance'do
        FactoryGirl.create(:api_key, key: token, permissions: %w(api_ec2_instance))
        post :update_info_from_aws, id: 45, format: 'json'
        expect(response).to_not be_success
      end
    end
  end
end
