# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "TeamName#{n}" }
    description "MyString"

    trait :with_ci_environment do
      after(:build) { |team| FactoryGirl.build(:ci_environment, team: team, chef_environment: team.name)}
    end
  end
end
