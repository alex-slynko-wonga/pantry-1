# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance do
    trait :bootstrapped do
      bootstrapped true
      booted true
      joined true
      state 'ready'
    end

    trait :running do
      bootstrapped true
      booted true
      joined true
      state 'ready'
    end

    trait :terminated do
      terminated_by { self.user }
      terminated true
      state 'terminated'
    end

    sequence(:name) { |n| "Name#{n}" }
    domain CONFIG['pantry']['domain']
    instance_id "MyString"
    platform "Lindows"
    chef_environment "MyChefEnvironment"
    run_list "role[ted]\r\nrecipe[ted]\r\nrecipe[ted::something]"
    security_group_ids ["sg-00000001","sg-00000002"]
    ami "i-111111"
    team
    user { FactoryGirl.build(:user, team: team) }
    volume_size 10
    flavor "t1.micro"
  end
end
