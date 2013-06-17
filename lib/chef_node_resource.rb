module ChefNodeResource
  def self.listNodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")
  end
end
