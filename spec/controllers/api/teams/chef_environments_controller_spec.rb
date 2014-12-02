require 'spec_helper'

RSpec.describe Api::Teams::ChefEnvironmentsController, type: :controller do

  describe "PUT 'update'" do

    let(:environment) { FactoryGirl.create(:environment, chef_environment: nil) }
    let(:params) { { team_id: environment.team_id, id: environment.id, chef_environment: 'env_name', format: 'json' } }
    let(:token) { SecureRandom.uuid }

    context 'with valid token' do
      before(:each) do
        request.headers['X-Auth-Token'] = token
        FactoryGirl.create(:api_key, key: token, permissions: %w(api_team_chef_environment))
      end

      it 'saves chef_environment' do
        put 'update', params
        expect(environment.reload.chef_environment).to eq('env_name')
      end

      it 'returns http success' do
        put 'update', params
        expect(response.status).to eq 204
      end
    end

    context 'without token' do
      it 'returns 404' do
        put 'update', params
        expect(response.status).to eq 404
      end
    end
  end
end
