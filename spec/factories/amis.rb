# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ami do
    sequence(:name) { |n| "AMI #{n}" }
    platform 'linux'
    sequence(:ami_id) { |n| "ami-1234a#{n}" }
    hidden false
  end
end
