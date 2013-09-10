# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bill do
    bill_date "2013-09-10"
    total_cost "9.99"
  end
end
