# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :environment do
    sequence(:name) { |n| "Environment#{n}" }
    description 'My description'
    sequence(:chef_environment) { |n| "env#{n}" }
    environment_type 'INT'
    team
  end

  factory :ci_environment, parent: :environment do
    environment_type 'CI'
    after(:build) { |environment| environment.team.ci_environment = environment }
  end
end
