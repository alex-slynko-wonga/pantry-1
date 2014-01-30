# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "TeamName#{n}" }
    description "MyString"

    trait :with_ci_environment do
      after(:create) { |team| team.ci_environment.update_attribute(:chef_environment, team.name) }
    end
  end
end
