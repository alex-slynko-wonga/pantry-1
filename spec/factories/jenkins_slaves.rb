# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :jenkins_slave, :class => 'JenkinsSlave' do
    ec2_instance
    jenkins_server
  end
end
