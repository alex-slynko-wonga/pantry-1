class InstanceSchedule < ActiveRecord::Base
  belongs_to :ec2_instance, inverse_of: :instance_schedule
  belongs_to :schedule

  accepts_nested_attributes_for :ec2_instance
  after_validation :set_event, on: :create

  def next_shutdown_time
    time = schedule.shutdown_time
    now = Time.current + 1.minute
    time = time.change(day: now.day, month: now.month, year: now.year)
    if schedule.weekend_only
      time += (5 - time.wday).days
      time += 7.days if now >= time
    else
      time += 1.day if now >= time
    end
    time
  end

  def next_start_time
    time = schedule.start_time
    now = Time.current + 1.minute
    time = time.change(day: now.day, month: now.month, year: now.year)
    if schedule.weekend_only
      time += (1 - time.wday).days
      time += 7.days if now >= time
    else
      time += 1.day if now >= time
      time += 2.day if time.saturday?
      time += 1.day if time.sunday?
    end
    time
  end

  private

  def set_event
    ec2_instance.schedule_next_event
  end
end
