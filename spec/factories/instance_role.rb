# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance_role do
    sequence(:name) { |n| "Role #{n}" }
    ami
    sequence(:chef_role) { |n| "Chef_role#{n}" }
    run_list 'role[test]'
    instance_size 't1.micro'
    disk_size 5
    security_group_ids ['ssg-111111']
    enabled true
  end
end
