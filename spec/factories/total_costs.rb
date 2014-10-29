# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :total_cost do
    cost '9.99'
    bill_date '2013-11-11'
  end
end
