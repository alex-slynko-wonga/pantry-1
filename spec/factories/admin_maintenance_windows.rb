# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin_maintenance_window, :class => 'Admin::MaintenanceWindow' do
    name "MyString"
    description "MyText"
    message "MyString"
    enabled false

    trait :enabled do
      enabled true
    end
    trait :closed do
      enabled false
      start_at "2014-04-01 01:00:00"
      end_at "2014-04-01 02:30:00"
    end
  end
end
