module ChefNodeResource
  def self.listNodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")
  end
  
  def self.find_by_name(name)
    query = Chef::Search::Query.new
    node = query.search('node',"name:#{name}").first
  end
    
end
