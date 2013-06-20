module ChefNodeResource
  def self.list_nodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")[0]
  end
end
