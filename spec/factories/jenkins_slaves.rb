# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jenkins_slave do
    ec2_instance { FactoryGirl.build(:ec2_instance, team: jenkins_server.team) }
    jenkins_server
  end
end
