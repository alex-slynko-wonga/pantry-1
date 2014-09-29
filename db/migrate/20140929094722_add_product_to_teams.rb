class AddProductToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :product, :string
    add_column :teams, :region, :string
  end
end
