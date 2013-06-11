module DataBagResource
  def self.create_or_update_item(data_bag_title, data_item, data)
    data_bag = Chef::DataBag.load(data_bag_title)
    data_bag_item = nil
    if data_bag[data_item]
      data_bag_item = Chef::DataBagItem.load(data_bag_title, data_item)
    else
      data_bag_item = Chef::DataBagItem.new
      data_bag_item['id'] = data_item
      data_bag_item.data_bag(data_bag_title)
    end
    data_bag_item.merge!(data)
    data_bag_item.save
  end
end
