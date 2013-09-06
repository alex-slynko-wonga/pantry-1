# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    sequence(:name) { |n| "Name#{n}" }
    domain CONFIG['pantry']['domain']
    instance_id "MyString"
    platform "Lindows"
    chef_environment "MyChefEnvironment"
    run_list "role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]"
    ami "i-111111"
    team
    user
  end
end
