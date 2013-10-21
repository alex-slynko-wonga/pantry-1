class AddRemovedToJenkinsSlaves < ActiveRecord::Migration
  def change
    add_column :jenkins_slaves, :removed, :boolean, default: false
  end
end
