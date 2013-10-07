require 'spec_helper'

describe Api::ChefNodesController do
  before(:each) do
    request.env['X-Auth-Token'] = CONFIG['pantry']['api_key']
    @ec2_instance = instance_double('Ec2Instance', id: 1)
    Ec2Instance.stub(:find).with("1").and_return(@ec2_instance)
  end
  
  describe "DELETE 'destroy'" do
    it "calls chef_node_delete" do
      @ec2_instance.should_receive(:chef_node_delete)
      delete :destroy, id: 1, format: 'json'
    end
    
    it "returns 204 status code" do
      @ec2_instance.stub(:chef_node_delete)
      delete :destroy, id: 1, format: 'json'
      response.code.should match /204/
    end
  end
end
