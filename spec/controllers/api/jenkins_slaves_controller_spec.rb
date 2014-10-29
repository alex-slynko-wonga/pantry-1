require 'spec_helper'

RSpec.describe Api::JenkinsSlavesController, type: :controller do
  describe '#update' do
    before(:each) do
      request.headers['X-Auth-Token'] = CONFIG['pantry']['api_key']
    end

    it 'should update removed attribute' do
      jenkins_slave = FactoryGirl.create(:jenkins_slave, removed: false)
      put :update, id: jenkins_slave.id, jenkins_slave: { removed: true }, format: :json
      jenkins_slave.reload
      expect(jenkins_slave).to be_removed
    end
  end
end
