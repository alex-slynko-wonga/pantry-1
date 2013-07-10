class AddTeamIdToEc2Instance < ActiveRecord::Migration
  def change
    add_column :ec2_instances, :team_id, :integer
  end
end