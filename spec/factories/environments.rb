# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :environment do
    sequence(:name) { |n| "Name#{n}" }
    description "My description"
    sequence(:chef_environment) { |n| "env#{n}" }
    environment_type "standard"
    team
  end
end
