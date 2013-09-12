# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jenkins_server do
    team
    ec2_instance

    trait :bootstrapped do
      association :ec2_instance, :bootstrapped
    end
  end
end
