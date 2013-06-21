require 'spec_helper'

describe ChefNodeResource do
  let(:node_name) { 'test' }
  let(:environment) {'test' }
  let(:role) {'test' }

  describe "#list_nodes" do
    let!(:node_with_role) { build_chef_node('node_with_role', environment, role) }
    let!(:node_without_role) { build_chef_node('node_without_role', environment) }
    let!(:node_without_env) { build_chef_node('node_without_env', nil, role) }

    it "finds nodes using only environment" do
      nodes = ChefNodeResource.list_nodes(environment, '*')
      expect(nodes).to have(2).items
    end

    it "finds nodes using only role" do
      nodes = ChefNodeResource.list_nodes('*', role)
      expect(nodes).to have(2).items
    end

    context "if node matches the environment and node params" do
      it "should return each node that matched the query" do
        nodes = ChefNodeResource.list_nodes(environment, role)
        expect(nodes.length).to be_eql 1
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

