class AddHiddenToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :hidden, :boolean
  end
end
