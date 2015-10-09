class IncreaseRunListSize < ActiveRecord::Migration
  def change
    change_column :ec2_instances, :run_list, :text, limit: 500
  end
end
