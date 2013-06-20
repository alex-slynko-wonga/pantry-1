class AddMachineToJobLog < ActiveRecord::Migration
  def change
    add_column :job_logs, :machine, :string
  end
end
