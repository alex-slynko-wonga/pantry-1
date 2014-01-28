# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "TeamName#{n}" }
    description "MyString"
    chef_environment { name.parameterize }

    trait :with_ci_environment do
      ci_environment
    end
  end
end
