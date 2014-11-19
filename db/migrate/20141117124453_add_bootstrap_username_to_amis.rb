class AddBootstrapUsernameToAmis < ActiveRecord::Migration
  def change
    add_column :amis, :bootstrap_username, :string
  end
end
