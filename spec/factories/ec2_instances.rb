# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    trait :running do
      instance_id "MyString"
      ip_address "MyString"
      state 'ready'
    end

    trait :terminated do
      instance_id "MyString"
      ip_address "MyString"
      terminated true
      state 'terminated'
    end

    sequence(:name) { |n| "InstanceName#{n}" }
    domain CONFIG['pantry']['domain']
    platform "Lindows"
    environment { FactoryGirl.build(:environment, team: team) }
    run_list "role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]"
    security_group_ids ["sg-00000001","sg-00000002"]
    ami "i-111111"
    team
    user { FactoryGirl.build(:user, team: team) }
    volume_size 10
    flavor "t1.micro"
  end

  factory :ci_ec2_instance, parent: :ec2_instance do
    environment { team.ci_environment || FactoryGirl.build(:ci_environment, team: team) }
    after(:build) { |instance| instance.environment.chef_environment ||= instance.name }
  end
end
