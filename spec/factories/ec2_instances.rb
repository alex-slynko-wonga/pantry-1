# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    name ""
    status ""
    instance_id "MyString"
    string "MyString"
  end
end
