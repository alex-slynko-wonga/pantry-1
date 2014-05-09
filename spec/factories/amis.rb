# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ami do
    name "MyAMI"
    platform "linux"
    ami_id "ami-x26d79d3"
    hidden false
  end
end
