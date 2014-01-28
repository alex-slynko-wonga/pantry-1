# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jenkins_server do
    team
    ec2_instance { FactoryGirl.build(:ci_ec2_instance, team: team) }

    trait :terminated do
      ec2_instance { FactoryGirl.build(:ci_ec2_instance, :terminated, team: team) }
    end

    trait :bootstrapped do
      ec2_instance { FactoryGirl.build(:ci_ec2_instance, :bootstrapped, team: team) }
    end
  end
end
