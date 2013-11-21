require 'spec_helper'

describe Api::ChefNodesController do
  before(:each) do
    request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
    @ec2_instance = instance_double('Ec2Instance', id: 1)
    Ec2Instance.stub(:find).with("1").and_return(@ec2_instance)
    @state = instance_double('Wonga::Pantry::Ec2InstanceState')
    Wonga::Pantry::Ec2InstanceState.stub(:new).and_return(@state)
  end
  
  describe "DELETE 'destroy'" do
    it "calls change_state" do
      @state.should_receive(:change_state).and_return(true)
      delete :destroy, id: 1, format: 'json'
    end
    
    it "returns 204 status code" do
      @state.stub(:change_state).and_return(true)
      delete :destroy, id: 1, format: 'json'
      response.code.should match /204/
    end
  end
end
