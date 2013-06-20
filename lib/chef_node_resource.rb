module ChefNodeResource
<<<<<<< HEAD
  def self.listNodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")
=======
  def self.list_nodes(environment, role)
    query = Chef::Search::Query.new
    nodes = query.search('node', "chef_environment:#{environment} AND role:#{role}")[0]
>>>>>>> contributer/TD-819_Node_Search_Resource
  end
end
