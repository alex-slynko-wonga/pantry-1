RSpec.describe Api::Ec2InstancesController, type: :controller do
  let(:token) { FactoryGirl.create(:api_key, permissions: permissions).key }

  before(:each) do
    request.headers['X-Auth-Token'] = token
  end

  describe '#update' do
    let(:user) { FactoryGirl.build(:user) }
    let(:permissions) { %w(api_ec2_instance) }
    let(:state) { instance_double(Wonga::Pantry::Ec2InstanceState, change_state!: true) }

    context 'with valid token' do
      before(:each) do
        expect(Ec2Instance).to receive(:find).with('45').and_return(instance_double(Ec2Instance))
        expect(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(state)
      end

      it 'updates an instance' do
        expect(state).to receive(:change_state!)
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
      end

      it 'returns http success' do
        put :update, id: 45, user_id: 1, terminated: true, format: 'json'
        expect(response).to be_success
      end
    end
  end

  describe '#update_info_from_aws' do
    let(:ec2_instance) { instance_double(Ec2Instance, update_info: true, id: 45) }
    let(:permissions) { %w(update_info_from_aws_api_ec2_instance) }

    context 'for instance with some id' do
      before(:each) do
        allow(Ec2Instance).to receive(:find).with('45').and_return(ec2_instance)
      end

      it 'returns http success' do
        post :update_info_from_aws, id: 45, format: 'json'
        expect(response).to be_success
      end

      context 'with permissions for api_ec2_instance' do
        let(:permissions) { %w(api_ec2_instance) }

        it 'forbid access for api_ec2_instance'do
          post :update_info_from_aws, id: 45, format: 'json'
          expect(response).to_not be_success
        end
      end
    end
  end

  describe '#start' do
    let(:ec2_instance) { instance_double(Ec2Instance, id: 12) }
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource', start_automatically: true) }
    let(:permissions) { %w(start_api_ec2_instance) }

    before(:each) do
      allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
      allow(Ec2Instance).to receive(:find).with('12').and_return(ec2_instance)
    end

    it 'call EC2 resource to start an instance' do
      expect(ec2_resource).to receive(:start_automatically)
      get :start, id: 12, format: 'json'
    end

    it 'returns http success' do
      post :start, id: 12, format: 'json'
      expect(response).to be_success
    end
  end

  describe '#stop' do
    let(:ec2_instance) { instance_double(Ec2Instance, id: 21) }
    let(:ec2_resource) { instance_double('Wonga::Pantry::Ec2Resource', stop_automatically: true) }
    let(:permissions) { %w(shut_down_api_ec2_instance) }

    before(:each) do
      allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
      allow(Ec2Instance).to receive(:find).with('21').and_return(ec2_instance)
    end

    it 'returns http success' do
      post :shut_down, id: 21, format: 'json'
      expect(response).to be_success
    end
  end

  describe '#ready_for_shutdown' do
    let(:permissions) { %w(ready_for_shutdown_api_ec2_instances) }

    it 'renders array' do
      allow(ScheduledEvent).to receive_message_chain('ready_for_shutdown.pluck').and_return([1, 2, 3])
      get :ready_for_shutdown, format: :json
      expect(JSON.parse(response.body)).to eq [1, 2, 3]
    end
  end

  describe '#ready_for_start' do
    let(:permissions) { %w(ready_for_start_api_ec2_instances) }

    it 'renders array' do
      allow(ScheduledEvent).to receive_message_chain('ready_for_start.pluck').and_return([1, 2, 3])
      get :ready_for_start, format: :json
      expect(JSON.parse(response.body)).to eq [1, 2, 3]
    end
  end
end
