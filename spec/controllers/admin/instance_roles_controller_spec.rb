require 'spec_helper'

describe Admin::InstanceRolesController do
  before(:each) do
    session[:user_id] = user.id
  end

  let(:ami) { FactoryGirl.create(:ami) }
  let(:instance_role) { FactoryGirl.create(:instance_role, ami: ami) }
  let(:instance_role_params) {
    { instance_role: FactoryGirl.attributes_for(:instance_role,
                                              name: 'my role',
                                              ami_id: ami.id,
                                              chef_role: 'some chef role',
                                              run_list: 'role[test]',
                                              instance_size: 't1.micro',
                                              disk_size: 100,
                                              enabled: false,
                                              security_group_ids: ['ssg-11111111']
                                             )}
    }

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
      it 'updates the instance role' do
        post 'update', id: instance_role.id, instance_role: { name: 'new instance role', security_group_ids: ['ssg-1111111'] }, format: :json
        expect(response).to be_redirect
      end

      it 'changes the name and enabled status' do
        post 'update', id: instance_role.id, instance_role: { name: 'some new instance role', enabled: true, security_group_ids: ['ssg-1111111'] }, format: :json
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

      it { should be_success }
    end
  end
end
