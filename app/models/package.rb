class Package < ActiveRecord::Base
  validates :name, presence: true
  validates :url, presence: true
  validates :version, presence: true
  validates :bag_title, presence: true
  validates :item_title, presence: true

  def update_data_bag
    if DataBagResource.create_or_update_item(bag_title, item_title, {name: name, url: url, version: version})
      update_attribute(:data_bag_updated_at, Time.now)
    end
  end
end
