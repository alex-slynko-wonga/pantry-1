source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'
gem 'mysql2'
gem 'omniauth-ldap', github: 'QuickbridgeLtd/omniauth-ldap', branch: 'newer_ldap'

gem 'syslogger'
gem 'haml-rails'
gem 'aws-sdk', '~> 1.25'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~> 2.3.2'
gem 'angularjs-rails', '~> 1.2.16'
gem 'rabl'
gem 'rack-ssl'
gem 'cache_digests'
gem "state_machine"
gem "newrelic_rpm", "~> 3.7"
gem 'net-ldap', github: "ruby-ldap/ruby-net-ldap"
gem "simple_form"
gem 'pundit'

group :development do
  gem 'quiet_assets'
  gem 'guard-bundler'
  gem 'guard-cucumber'
  gem 'guard-migrate'
  gem 'guard-rspec', '4.2.6'
  gem 'thin'
  gem 'bundler-audit'
  gem 'codesake-dawn', require: false
  gem 'letter_opener'
end

group :test do
  # gem 'selenium-webdriver' # uncomment if you want to use @selenium in you cucmber tests
  gem 'launchy'
  gem 'brakeman', require: false
  gem 'capybara-webkit'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'timecop'
  gem "therubyracer", require: 'v8'
  gem "stepdown", require: false
end

group :test, :development do
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'factory_girl_rails'
  gem 'pry-debugger'
  gem 'pry-rails'
  gem 'rspec-rails', '3.0.0.beta1'
  gem 'rspec-core', '3.0.0.beta1'
  gem 'rspec', '3.0.0.beta1'
end
