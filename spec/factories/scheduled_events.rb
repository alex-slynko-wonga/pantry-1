FactoryGirl.define do
  factory :scheduled_start_event, class: ScheduledEvent do
    ec2_instance
    event_time { Time.now }
    event_type 'start'
  end

  factory :scheduled_shutdown_event, class: ScheduledEvent do
    ec2_instance
    event_time { Time.now }
    event_type 'shutdown'
  end
end
