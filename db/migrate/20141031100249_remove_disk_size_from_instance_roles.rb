class RemoveDiskSizeFromInstanceRoles < ActiveRecord::Migration
  def change
    remove_column :instance_roles, :disk_size, :integer
  end
end
