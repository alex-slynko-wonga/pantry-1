class AddDataBagUpdatedAtToPackage < ActiveRecord::Migration
  def change
    add_column :packages, :data_bag_updated_at, :datetime
  end
end
