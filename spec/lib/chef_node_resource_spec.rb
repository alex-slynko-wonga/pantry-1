require 'spec_helper'

describe ChefNodeResource do
  let(:node_name) { 'test' }
  let(:environment) {'test' }
  let(:role) {'test' }
  describe "#get_list_of_nodes" do
    context "if node matches the environment and node params" do
      it "should return each node that matched the query" do
        search = mock
        Chef::Search::Query.stub(:new).and_return(search)
        search.stub(:search).with("node", "chef_environment:env AND role:role").and_return([['node']])
        
        nodes = ChefNodeResource.list_nodes('env', 'role')
        
        expect(nodes.length).to be_eql 1
        expect(nodes[0]).to be_eql 'node'
      end
    end
  end
end