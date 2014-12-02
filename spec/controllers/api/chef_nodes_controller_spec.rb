RSpec.describe Api::ChefNodesController, type: :controller do
  let(:team) { FactoryGirl.build(:team) }
  let(:user) { FactoryGirl.build(:user, team: team) }
  let(:token) { SecureRandom.uuid }

  before(:each) do
    request.headers['X-Auth-Token'] = token
    @ec2_instance = instance_double('Ec2Instance', id: 1)
    allow(@ec2_instance).to receive(:user).and_return(user)
    allow(Ec2Instance).to receive(:find).with('1').and_return(@ec2_instance)
    @state = instance_double('Wonga::Pantry::Ec2InstanceState')
    allow(Wonga::Pantry::Ec2InstanceState).to receive(:new).and_return(@state)
    @user = instance_double('User', id: 1)
    allow(User).to receive(:find).with(1).and_return(@user)
    FactoryGirl.create(:api_key, key: token, permissions: %w(api_chef_node))
  end

  describe "DELETE 'destroy'" do
    it 'calls change_state' do
      expect(@state).to receive(:change_state).and_return(true)
      delete :destroy, id: 1, user_id: 1, format: 'json'
    end

    it 'returns 204 status code' do
      allow(@state).to receive(:change_state).and_return(true)
      delete :destroy, id: 1, user_id: 1, format: 'json'
      expect(response.code).to match(/204/)
    end

    it 'returns 404 status code when api key is not present' do
      request.headers['X-Auth-Token'] = SecureRandom.uuid
      delete :destroy, id: 1, user_id: 1, format: 'json'
      expect(response.code).to match(/404/)
    end

    it 'returns 404 status code when request is not permitted' do
      token = SecureRandom.uuid
      request.headers['X-Auth-Token'] = token
      FactoryGirl.create(:api_key, key: token, permissions: %w(update_from_aws_api_ec2_instances))
      delete :destroy, id: 1, user_id: 1, format: 'json'
      expect(response.code).to match(/404/)
    end
  end
end
