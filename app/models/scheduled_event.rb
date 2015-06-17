class ScheduledEvent < ActiveRecord::Base
  belongs_to :ec2_instance

  scope :ready_for_shutdown, -> (time = Time.current) { where(event_type: 'shutdown').where('scheduled_events.event_time < ?', time + 10.minutes) }
  scope :ready_for_start, -> (time = Time.current) { where(event_type: 'start').where('scheduled_events.event_time < ?', time + 10.minutes) }
end
