FactoryGirl.define do
  factory :schedule do
    start_time '2015-02-26 08:00:00'
    shutdown_time '2015-02-26 20:00:00'
    team
    weekend_only false
  end
end
