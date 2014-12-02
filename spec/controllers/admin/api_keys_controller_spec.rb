require 'spec_helper'

RSpec.describe Admin::ApiKeysController, type: :controller do
  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
  end

  let(:api_key) { FactoryGirl.create(:api_key) }

  context 'user is not a superadmin' do
    let(:user) { FactoryGirl.build :user }

    it 'returns a 404 status' do
      %w(index new).each do |action|
        get action
        expect(response.status).to eq 404
      end
    end
  end

  context 'user is a superadmin' do
    let(:user) { FactoryGirl.build :superadmin }

    describe "POST 'create'" do
      it 'creates a new api key' do
        expect do
          post 'create',
               api_key: {
                 name: 'new key',
                 key: '234',
                 permissions: %w(something)
               },
               format: :json
        end.to change(ApiKey, :count).by(1)
      end
    end

    describe "PUT 'update'" do
      let(:params) { { id: api_key.id, api_key: { name: 'some new api key', key: '5461111111', permissions: %w(one two) }, format: :json } }

      it 'updates the api key' do
        post 'update', params
        expect(response).to be_redirect
      end

      it 'changes the name and permissions' do
        post 'update', params
        expect(api_key.reload.name).to eq 'some new api key'
        expect(api_key.reload.permissions).to eq(%w(one two))
      end
    end

    describe "DELETE 'destroy'" do
      let!(:api_key) { FactoryGirl.create(:api_key) }

      it 'deletes an api key' do
        expect { delete :destroy, id: api_key.id }.to change(ApiKey, :count).by(-1)
      end
    end

    describe "GET 'edit'" do
      subject { get 'edit', id: api_key.id }

      it { is_expected.to be_success }
    end
  end
end
