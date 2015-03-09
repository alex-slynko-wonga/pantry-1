# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    trait :running do
      instance_id 'MyString'
      ip_address 'MyString'
      state 'ready'
    end

    trait :terminated do
      instance_id 'MyString'
      ip_address 'MyString'
      terminated true
      state 'terminated'
    end

    transient do
      volume_size 100
      additional_volume_size nil
    end

    sequence(:name) { |n| "InstanceName#{n}" }
    domain CONFIG['pantry']['domain']
    platform 'Lindows'
    environment { association(:environment, team: team, strategy: @build_strategy.class) }
    run_list "role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]"
    security_group_ids ['sg-00000001', 'sg-00000002']
    ami 'i-111111'
    team
    user { FactoryGirl.build(:user, team: team) }
    flavor 't1.micro'

    ec2_volumes do
      volumes = [association(:ec2_volume, size: volume_size, ec2_instance: @instance, strategy: @build_strategy.class)]
      volumes << association(:ec2_volume, size: additional_volume_size, ec2_instance: @instance, strategy: @build_strategy.class) if additional_volume_size
      volumes
    end
  end

  factory :ci_ec2_instance, parent: :ec2_instance do
    environment { team.ci_environment || FactoryGirl.build(:ci_environment, team: team) }
    after(:build) do |instance|
      instance.environment.chef_environment ||= instance.name
      instance.environment.save if instance.environment.persisted?
    end
  end
end
