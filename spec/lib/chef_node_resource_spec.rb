require 'spec_helper'

describe ChefNodeResource do
  let(:node_name) { 'awinpaintwwwl01.test.example.com' }
  let(:environment) {'awinpaint' }
  let(:role) {'*' }
  describe "#get_list_of_nodes" do
    context "if node matches the environment and node params" do
      it "should return each node that matched the query" do
        nodes = [Chef::Node.stub(:name).with(node_name)]
        ChefNodeResource.stub(:listNodes).with(environment, role).and_return(nodes)    
        expect(nodes.length).to be_eql 1 
      end
    end
  end
  describe "#get_single_node" do
    context "if node matches the name param" do
      it "should return a single node that matchs the query" do
        nodes = [Chef::Node.stub(:name).with(node_name)]
        ChefNodeResource.stub(:findByName).with(node_name).and_return(nodes)
        expect(nodes.length).to be_eql 1
      end
    end    
  end
end
