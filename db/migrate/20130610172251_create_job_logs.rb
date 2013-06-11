class CreateJobLogs < ActiveRecord::Migration
  def change
    create_table :job_logs do |t|
      t.integer :job_id
      t.text :log_text

      t.timestamps
    end
  end
end
