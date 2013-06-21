module ChefBuilders
  def self.included(klass)
    if klass.respond_to?(:after)
      klass.after(:each) do
        delete_chef_stuff
      end
    end
  end

  def build_chef_node(name, environment=nil, role=nil, os='linux')
    node = Chef::Node.new
    node.name(name)
    node.default['os'] = os
    node.chef_environment = environment if environment
    unless role.nil?
      role = build_chef_role(role) if role.is_a? String
      node.run_list << role.to_s
    end
    store_chef_stuff(node)
    node.save
  end

  def build_chef_data_bag(name)
    bag = Chef::DataBag.new
    bag.name(name)
    store_chef_stuff(bag)
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
      store_chef_stuff(role)
      role.create
    end
  end

  private
  def store_chef_stuff(chef_object)
    chef_stuff << chef_object
  end

  def delete_chef_stuff
    chef_stuff.reverse.each do |chef_object|
      chef_object.destroy rescue nil
    end
    chef_stuff.clear
  end

  def chef_stuff
    @chef_stuff ||= []
  end
end
