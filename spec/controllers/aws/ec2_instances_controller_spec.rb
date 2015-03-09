require 'json'

RSpec.describe Aws::Ec2InstancesController, type: :controller do
  let(:ec2_resource)    { instance_double('Wonga::Pantry::Ec2Resource') }
  let(:user) { FactoryGirl.create(:user, team: team) }
  let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, team: team) }
  let(:instance_price) { instance_double(Wonga::Pantry::PricingList, retrieve_price_list: nil) }
  let(:aws_adapter) { instance_double('Wonga::Pantry::AWSAdapter', iam_role_list: nil) }

  before(:each) do
    session[:user_id] = user.id
    allow(controller).to receive(:price_list).and_return(instance_price)
    allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
    allow(Wonga::Pantry::AWSAdapter).to receive(:new).and_return(aws_adapter)
  end

  let(:team) { FactoryGirl.create(:team) }
  let(:environment) { FactoryGirl.create(:environment, team: team) }

  describe '#new' do
    it 'returns http success' do
      get 'new'
      expect(response).to be_success
    end

    it 'sets the team if team_id is given' do
      get 'new', team_id: team.id
      expect(assigns(:ec2_instance).team_id).to eq(team.id)
    end

    context 'with prefilled params' do
      let(:reference_instance) { FactoryGirl.create(:ec2_instance) }

      it 'fill required fields' do
        get 'new', id: reference_instance.id
        expect(assigns(:ec2_instance).environment_id).to eq(reference_instance.environment_id)
      end
    end
  end

  describe "POST 'create'" do
    let(:ec2_instance_params) do
      { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                                 name: 'InstanceName',
                                                 user_id: user.id,
                                                 ami: FactoryGirl.create(:ami).ami_id,
                                                 environment_id: environment.id
                                                ).merge(volume_size: 100) }
    end

    let(:adapter) { instance_double('Wonga::Pantry::Ec2Adapter', platform_for_ami: 'Winux', flavors: [], generate_volumes: [FactoryGirl.build(:ec2_volume)]) }
    let(:ec2_instance) { assigns(:ec2_instance) }

    before(:each) do
      allow(ec2_resource).to receive(:boot)
      allow(Wonga::Pantry::Ec2Adapter).to receive(:new).and_return(adapter)
      post :create, ec2_instance_params
    end

    it 'uses ec2 adapter to get os' do
      expect(adapter).to have_received(:platform_for_ami)
      expect(ec2_instance.platform).to eq('Winux')
    end

    it 'uses ec2_resource to boot' do
      expect(ec2_resource).to have_received(:boot)
    end

    it 'creates valid instance' do
      expect(ec2_instance).to be_valid
    end

    context 'with instance role' do
      let(:instance_role) { FactoryGirl.create(:instance_role) }
      let(:ec2_instance_params) do
        { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                                   name: 'InstanceName',
                                                   team_id: team.id,
                                                   user_id: user.id,
                                                   environment_id: environment.id,
                                                   instance_role_id: instance_role.id
                                                  )
        }
      end

      it 'uses ec2_resource to boot' do
        expect(ec2_resource).to have_received(:boot)
      end

      it 'creates valid instance' do
        expect(ec2_instance).to be_valid
      end
    end

    context 'with custom_ami in params' do
      let(:ec2_instance_params) do
        { ec2_instance: FactoryGirl.attributes_for(:ec2_instance,
                                                   name: 'InstanceName',
                                                   team_id: team.id,
                                                   user_id: user.id,
                                                   environment_id: environment.id
                                                  ),
          custom_ami: custom_ami
        }
      end
      let(:custom_ami) { 'someami' }

      context 'when user is authorized to use custom_ami' do
        let(:user) { FactoryGirl.create(:user, team: team, role: 'superadmin') }

        it 'sets custom ami' do
          expect(ec2_instance.ami).to eq(custom_ami)
        end
      end

      it 'skipped' do
        expect(ec2_instance.ami).not_to eq(custom_ami)
      end
    end
  end

  context '#show' do
    it 'should be success' do
      get :show, id: ec2_instance.id
      expect(response).to be_success
    end
  end

  context '#destroy' do
    before(:each) do
      allow(ec2_resource).to receive(:terminate)
      request.env['HTTP_REFERER'] = 'test_ref'
    end

    it 'should redirect' do
      delete :destroy, id: ec2_instance.id
      expect(response).to redirect_to('test_ref')
    end

    it 'terminates instance if transition acceptable' do
      delete :destroy, id: ec2_instance.id
      expect(ec2_resource).to have_received(:terminate)
    end
  end

  context '#cleanup' do
    let(:ec2_instance_terminated) { FactoryGirl.create(:ec2_instance, state: 'booting', team: team, user: user) }
    before(:each) do
      allow(ec2_resource).to receive(:out_of_band_cleanup)
    end

    it 'should be success' do
      delete :cleanup, id: ec2_instance_terminated.id
      expect(response).to be_success
    end

    it 'make machine cleanup if transition acceptable' do
      delete :cleanup, id: ec2_instance_terminated.id
      expect(ec2_resource).to have_received(:out_of_band_cleanup)
    end
  end

  describe "PUT 'update'" do
    let(:ec2_resource)    { instance_double('Wonga::Pantry::Ec2Resource') }

    context 'shutting_down' do
      before(:each) do
        allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
        allow(ec2_resource).to receive(:stop)
      end

      it 'initiates shut down using json format' do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'shutdown_now', format: 'json'
        expect(response).to be_success
        expect(ec2_resource).to have_received(:stop)
      end

      it 'initiates shut down using html format from instance' do
        request.env['HTTP_REFERER'] = aws_ec2_instance_url(ec2_instance)
        put :update, id: ec2_instance.id, event: 'shutdown_now'
        expect(response).to redirect_to [:aws, ec2_instance]
        expect(ec2_resource).to have_received(:stop)
      end

      it 'initiates shut down using html format from slave' do
        request.env['HTTP_REFERER'] = 'http://test.host/jenkins_servers/1/jenkins_slaves/1'
        put :update, id: ec2_instance.id, event: 'shutdown_now'
        expect(response).to redirect_to 'http://test.host/jenkins_servers/1/jenkins_slaves/1'
        expect(ec2_resource).to have_received(:stop)
      end
    end

    context 'starting' do
      let(:ec2_instance) { FactoryGirl.create(:ec2_instance, :running, team: team, state: 'shutdown') }
      before(:each) do
        allow(Wonga::Pantry::Ec2Resource).to receive(:new).and_return(ec2_resource)
        allow(ec2_resource).to receive(:start)
      end

      it 'initiates start using json format' do
        put :update, id: ec2_instance.id, ec2_instance: {}, event: 'start_instance', format: 'json'
        expect(response).to be_success
        expect(ec2_resource).to have_received(:start)
      end

      it 'initiates start using html format' do
        request.env['HTTP_REFERER'] = aws_ec2_instance_url(ec2_instance)
        put :update, id: ec2_instance.id, event: 'start_instance'
        expect(response).to redirect_to [:aws, ec2_instance]
        expect(ec2_resource).to have_received(:start)
      end
    end
  end
end
