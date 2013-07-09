# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    name "MyString"
    status "Pending"
    instance_id "MyString"
  end
end
