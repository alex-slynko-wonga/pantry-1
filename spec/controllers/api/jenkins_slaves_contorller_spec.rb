require 'spec_helper'

describe Api::JenkinsSlavesController do
  describe "#update" do
    before(:each) do
      request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
    end
    
    it "should update removed attribute" do
      jenkins_slave = FactoryGirl.create(:jenkins_slave, removed: false)
      put :update, id: jenkins_slave.id, jenkins_slave: { removed: true }
      jenkins_slave.reload
      jenkins_slave.removed.should be_true
    end
  end
end