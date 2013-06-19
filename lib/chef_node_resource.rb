module ChefNodeResource
  def self.listNodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")
  end
  def self.findByName(name)
    query = Chef::Search::Query.new
    node = query.search('node',"name:#{name}").first
  end
  
  
end
