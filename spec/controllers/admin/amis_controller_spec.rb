require 'spec_helper'

describe Admin::AmisController do
  before(:each) do
    session[:user_id] = user.id
  end

  let(:ami) { FactoryGirl.create(:ami) }

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
      it 'creates a new ami' do
        expect do
          post 'create',
            ami: {
              ami_id: 'ami-00000001',
              name: 'windows_sdk_server',
              hidden: true,
              platform: 'linux'
            },
            format: :json
        end.to change(Ami, :count).by(1)
      end
    end

    describe "PUT 'update'" do
      it 'updates an ami' do
        post 'update', id: ami.id, ami: { name: 'windows_sdk_server', hidden: true }, format: :json
        expect(response).to be_redirect
      end

      it 'changes the name and hidden attributes' do
        post 'update', id: ami.id, ami: { name: 'windows_sdk_server', hidden: true }, format: :json
        expect(ami.reload.name).to eq 'windows_sdk_server'
      end

      it 'does not update ami with a different platform' do
        post 'update', id: ami.id, ami: { platform: 'windows_test' }
        expect(flash[:error]).to match("AMI cant't be updated with a different platform")
        expect(ami.platform).to eq 'linux'
      end
    end

    describe "DELETE 'destroy'" do
      let!(:ami) { FactoryGirl.create(:ami) }

      it 'deletes an ami' do
        expect { delete :destroy, id: ami.id }.to change(Ami, :count).by(-1)
      end
    end

    describe "GET 'edit'" do
      subject { get 'edit', id: ami.id }

      it { should be_success }
    end
  end
end
