# rubocop:disable all
class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table 'delayed_jobs'
    drop_table 'job_logs'
    drop_table 'jobs'
    drop_table 'packages'
  end

  def down
    create_table 'job_logs', force: true do |t|
      t.integer 'job_id'
      t.text 'log_text'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end

    create_table 'jobs', force: true do |t|
      t.string 'name'
      t.text 'description'
      t.string 'status'
      t.datetime 'start_time'
      t.datetime 'end_time'
      t.datetime 'created_at',  null: false
      t.datetime 'updated_at',  null: false
    end

    create_table 'packages', force: true do |t|
      t.string 'name'
      t.string 'version'
      t.string 'url'
      t.datetime 'created_at',          null: false
      t.datetime 'updated_at',          null: false
      t.string 'bag_title'
      t.string 'item_title'
      t.datetime 'data_bag_updated_at'
    end
    create_table 'delayed_jobs', force: true do |t|
      t.integer 'priority',   default: 0
      t.integer 'attempts',   default: 0
      t.text 'handler'
      t.text 'last_error'
      t.datetime 'run_at'
      t.datetime 'locked_at'
      t.datetime 'failed_at'
      t.string 'locked_by'
      t.string 'queue'
      t.datetime 'created_at',                null: false
      t.datetime 'updated_at',                null: false
    end

    add_index 'delayed_jobs', %w(priority run_at), name: 'delayed_jobs_priority'
  end
end
# rubocop:enable all
