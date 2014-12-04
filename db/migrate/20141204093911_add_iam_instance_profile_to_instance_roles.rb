class AddIamInstanceProfileToInstanceRoles < ActiveRecord::Migration
  def change
    add_column :instance_roles, :iam_instance_profile, :string
  end
end
