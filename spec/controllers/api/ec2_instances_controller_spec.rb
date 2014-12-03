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

  describe '#start' do
    let(:token) { SecureRandom.uuid }
    let(:ec2_instance) { instance_double(Ec2Instance, id: 12) }
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource', start_automatically: true) }

    before(:each) do
      request.headers['X-Auth-Token'] = token
      allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
      allow(Ec2Instance).to receive(:find).with('12').and_return(ec2_instance)
    end

    it 'returns http success' do
      FactoryGirl.create(:api_key, key: token, permissions: %w(start_api_ec2_instance))
      get :start, id: 12, format: 'json'
      expect(response).to be_success
    end

    it 'call EC2 resource to start an instance' do
      FactoryGirl.create(:api_key, key: token, permissions: %w(start_api_ec2_instance))
      expect(ec2_resource).to receive(:start_automatically)
      get :start, id: 12, format: 'json'
    end
  end

  describe '#stop' do
    let(:token) { SecureRandom.uuid }
    let(:ec2_instance) { instance_double(Ec2Instance, id: 21) }
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource', stop_automatically: true) }

    before(:each) do
      request.headers['X-Auth-Token'] = token
      allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
      allow(Ec2Instance).to receive(:find).with('21').and_return(ec2_instance)
    end

    it 'returns http success' do
      FactoryGirl.create(:api_key, key: token, permissions: %w(shut_down_api_ec2_instance))
      post :shut_down, id: 21, format: 'json'
      expect(response).to be_success
    end

    it 'call EC2 resource to start an instance' do
      FactoryGirl.create(:api_key, key: token, permissions: %w(shut_down_api_ec2_instance))
      expect(ec2_resource).to receive(:stop_automatically)
      post :shut_down, id: 21, format: 'json'
    end
  end
end
