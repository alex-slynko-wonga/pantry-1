# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

if Rails.env.test? || Rails.env.development?
  require 'rubocop/rake_task'

  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop) do |task|
    # don't abort rake on failure
    task.fail_on_error = true
  end

  task default: :rubocop
end

desc 'Brakeman'
task :security do |_t, args|
  require 'brakeman'

  files = args[:output_files].split(' ') if args[:output_files]
  Brakeman.run app_path: '.', output_files: files, print_report: true
end

Wonga::Pantry::Application.load_tasks
