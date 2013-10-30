# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ec2_instance_cost do
    bill_date { Date.today.end_of_month }
    cost "9.99"
    ec2_instance
  end
end
