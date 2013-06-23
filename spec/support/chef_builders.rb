require 'chef_zero'
require 'chef_zero/server'

module ChefBuilders
  def build_chef_node(name, environment=nil, role=nil, os='linux')
    node = Chef::Node.new
    node.name(name)
    node.default['os'] = os
    node.chef_environment = environment if environment
    unless role.nil?
      role = build_chef_role(role) if role.is_a? String
      node.run_list << role.to_s
    end
    node.save
  end

  def build_chef_data_bag(name)
    bag = Chef::DataBag.new
    bag.name(name)
    bag.create
  end

  def build_chef_data_bag_item(name, data_bag)
    item = Chef::DataBagItem.new
    item['id'] = name
    data_bag_title = if data_bag.is_a? Chef::DataBag
                       data_bag.name
                     else
                       data_bag
                     end
    item.data_bag(data_bag_title)
    item.create
  end

  def build_chef_role(name)
    if Chef::Role.list.keys.include? name
      Chef::Role.load name
    else
      role = Chef::Role.new
      role.name(name)
      role.create
    end
  end
end

class ChefZero::SingleServer
  def initialize
    @server = ChefZero::Server.new
    @server.start_background
  end
  include Singleton

  def clean
    @server.clear_data
  end
end
