# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rubocop/rake_task'
require File.expand_path('../config/application', __FILE__)

if Rails.env.test? || Rails.env.development?
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop) do |task|
    # only show the files with failures
    task.formatters = ['files']
    # don't abort rake on failure
    task.fail_on_error = true
  end
end

Wonga::Pantry::Application.load_tasks
