source 'https://rubygems.org'

gem 'rails', '~> 3.2.14'
gem 'mysql2'
gem 'omniauth-ldap'

gem 'strong_parameters'
gem 'haml-rails'
gem 'chef','~> 11.8.0'
gem 'aws-sdk', '~> 1.25.0'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass', '~> 2.3.2'
gem 'angularjs-rails', '~> 1.0.8'
gem 'rabl'
gem 'simple_form'
gem 'rack-ssl'
gem 'cache_digests'

group :development do
  gem 'quiet_assets'
  gem 'guard-bundler'
  gem 'guard-cucumber'
  gem 'guard-migrate'
  gem 'guard-rspec'
  gem 'thin'
  gem 'bundler-audit'
end

group :test do
  # gem 'selenium-webdriver' # uncomment if you want to use @selenium in you cucmber tests
  gem 'launchy'
  gem 'brakeman', :require => false
  gem 'capybara-webkit'
  gem 'chef-zero'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-fire'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'timecop'
  gem "therubyracer", require: 'v8'
  gem "stepdown", require: false
end

group :test, :development do
  gem 'factory_girl_rails'
  gem 'pry-debugger'
  gem 'pry-rails'
  gem 'rspec-rails'
end
