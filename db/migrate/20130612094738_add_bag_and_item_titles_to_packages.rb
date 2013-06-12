class AddBagAndItemTitlesToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :bag_title, :string
    add_column :packages, :item_title, :string
  end
end
