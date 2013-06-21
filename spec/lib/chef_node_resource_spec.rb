require 'spec_helper'

describe ChefNodeResource do
  let(:node_name) { 'test' }
  let(:environment) {'test' }
  let(:role) {'test' }

  describe "#list_nodes" do
    context "if node matches the environment and node params" do
      it "should return each node that matched the query" do
        search = double
        Chef::Search::Query.stub(:new).and_return(search)
        search.stub(:search).with("node", "chef_environment:env AND role:role").and_return([['node']])

        nodes = ChefNodeResource.list_nodes('env', 'role')

        expect(nodes.length).to be_eql 1
        expect(nodes[0]).to be_eql 'node'
      end
    end
  end

  describe "#find_by_name" do
    context "if node matches the name param" do
      it "should return a single node that matchs the query" do
        search = double
        Chef::Search::Query.stub(:new).and_return(search)
        search.stub(:search).with("node", "name:name").and_return([['node']])

        nodes = ChefNodeResource.find_by_name('name')

        expect(nodes.length).to be_eql 1
        expect(nodes[0]).to be_eql 'node'
      end
    end
  end
end

