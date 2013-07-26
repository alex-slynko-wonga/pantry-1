# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    name "MyString"
    domain "MyDomain"
    instance_id "MyString"
    team
    user
  end
end
