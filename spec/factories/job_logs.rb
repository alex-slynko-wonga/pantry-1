# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_log do
    job_id 1
    log_text "MyText"
  end
end
