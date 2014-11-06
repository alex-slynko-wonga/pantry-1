require 'spec_helper'

RSpec.describe Admin::InstanceRolesController, type: :controller do
  before(:each) do
    session[:user_id] = user.id
    allow(controller).to receive(:price_list).and_return(instance_price)
  end

  let(:ami) { FactoryGirl.create(:ami) }
  let(:instance_role) { FactoryGirl.create(:instance_role, ami: ami) }
  let(:instance_price) { instance_double(Wonga::Pantry::PricingList, retrieve_price_list: nil) }
  let(:instance_role_params) do
    { instance_role: FactoryGirl.attributes_for(:instance_role, ami_id: ami.id) }
  end

  context 'user is not a superadmin' do
    let(:user) { FactoryGirl.create :user }

    it 'returns a 404 status' do
      %w(index new).each do |action|
        get action
        expect(response.status).to eq 404
      end
    end
  end

  context 'user is a superadmin' do
    let(:user) { FactoryGirl.create :superadmin }

    describe "POST 'create'" do
      it 'creates a new instance role' do
        expect do
          post 'create',
               instance_role_params,
               format: :json
        end.to change(InstanceRole, :count).by(1)
      end
    end

    describe "PUT 'update'" do
      let(:params) { { id: instance_role.id, instance_role: { name: 'some new instance role', security_group_ids: ['ssg-1111111'] }, format: :json } }

      it 'updates the instance role' do
        post 'update', params
        expect(response).to be_redirect
      end

      it 'changes the name and enabled status' do
        post 'update', params
        expect(instance_role.reload.name).to eq 'some new instance role'
        expect(instance_role.reload.enabled).to eq true
      end
    end

    describe "DELETE 'destroy'" do
      let!(:instance_role) { FactoryGirl.create(:instance_role) }

      it 'deletes an instance role' do
        expect { delete :destroy, id: instance_role.id }.to change(InstanceRole, :count).by(-1)
      end
    end

    describe "GET 'edit'" do
      subject { get 'edit', id: instance_role.id }

      it { is_expected.to be_success }
    end
  end
end
