# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job do
    name "MyString"
    description "MyText"
    status "MyString"
    start_time "2013-06-10 18:34:17"
    end_time "2013-06-10 18:34:17"
  end
end
