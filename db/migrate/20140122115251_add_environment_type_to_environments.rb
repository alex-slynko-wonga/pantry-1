class AddEnvironmentTypeToEnvironments < ActiveRecord::Migration
  def change
    add_column :environments, :environment_type, :string
  end
end
