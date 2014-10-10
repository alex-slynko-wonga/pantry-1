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

    transient do
      volume_size 105
      additional_volume_size nil
    end

    trait :for_jenkins_server do
      sequence(:name) { |n| "Jenkins Server Role #{n}" }
    end

    trait :for_jenkins_slave do
      sequence(:name) { |n| "Jenkins Agent Role #{n}" }
    end

    ec2_volumes do
      volumes = [association(:ec2_volume_for_role, size: volume_size, instance_role: @instance, strategy: @build_strategy.class)]
      if additional_volume_size
        volumes << association(:ec2_volume_for_role, size: additional_volume_size, instance_role: @instance, strategy: @build_strategy.class)
      end
      volumes
    end
  end
end
