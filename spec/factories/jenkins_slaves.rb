# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jenkins_slave do
    ec2_instance { FactoryGirl.build(:ci_ec2_instance, team: jenkins_server.team) }
    jenkins_server

    trait :bootstrapped do
      ec2_instance { FactoryGirl.build(:ci_ec2_instance, :bootstrapped, team: jenkins_server.team) }
    end
  end
end
