# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instance_role do
    sequence(:name) { |n| "Role #{n}" }
    ami
    sequence(:chef_role) { |n| "Chef_role#{n}" }
    run_list 'role[test]'
    instance_size 't1.micro'
    security_group_ids ['ssg-111111']
    enabled true
    disk_size 10

    trait :for_jenkins_server do
      sequence(:name) { |n| "Jenkins Server Role #{n}" }
    end

    trait :for_jenkins_slave do
      sequence(:name) { |n| "Jenkins Agent Role #{n}" }
    end
  end
end
