class AddTeamInfoToJobs < ActiveRecord::Migration
  def change
      add_column :delayed_jobs, :team_id, :integer
      add_column :job_logs, :machine, :string
      add_column :jobs, :machine, :integer
  end
end
