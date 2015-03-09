When(/^it is (\d+)\.(\d+) (am|pm) on (\w+)$/) do |hour, minute, pm_or_am, day_of_week|
  weekdays = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  t = Time.now
  days_to = weekdays.index(day_of_week) - t.wday + 1
  days_to += 7 if days_to < 0
  t += days_to.days
  hour = hour.to_i + 12 if pm_or_am == 'pm'
  t = t.change(hour: hour, min: minute.to_i)
  Timecop.travel t
end

Given(/^schedule for "(.*?)" is to shutdown at (\d+) pm (every day|before weekend)$/) do |name, time, weekend_or_every_day|
  ec2_instance = Ec2Instance.where(name: name).first!
  weekend_only = weekend_or_every_day == 'before weekend'
  shutdown_time = Time.now.change(hour: time.to_i + 12, min: 0, sec: 0)
  schedule = ec2_instance.schedules.first
  if schedule
    schedule.update_attribute(:shutdown_time, shutdown_time)
  else
    FactoryGirl.create(:instance_schedule, ec2_instance: ec2_instance, shutdown_time: shutdown_time, weekend_only: weekend_only)
  end
end

Given(/^schedule for "(.*?)" is to start at (\d+) am (every day|after weekend)$/) do |name, time, weekend_or_every_day|
  ec2_instance = Ec2Instance.where(name: name).first!
  weekend_only = weekend_or_every_day == 'after weekend'
  start_time = Time.now.change(hour: time.to_i, min: 0, sec: 0)
  schedule = ec2_instance.schedules.first
  if schedule
    schedule.update_attribute(:start_time, start_time)
  else
    FactoryGirl.create(:instance_schedule, ec2_instance: ec2_instance, start_time: start_time, weekend_only: weekend_only)
  end
end

Then(/^no instances are expected to shutdown$/) do
  api_key = FactoryGirl.create(:api_key, permissions: %w(ready_for_shutdown_api_ec2_instances))
  header 'X-Auth-Token', api_key.key
  response = get '/api/ec2_instances/ready_for_shutdown', format: :json
  expect(response.body).to eq '[]'
end

Then(/^"(.*?)" instance is expected to shutdown$/) do |name|
  api_key = FactoryGirl.create(:api_key, permissions: %w(ready_for_shutdown_api_ec2_instances))
  header 'X-Auth-Token', api_key.key
  response = get '/api/ec2_instances/ready_for_shutdown', format: :json
  instance = Ec2Instance.where(name: name).first!
  expect(response.body).to eq "[#{instance.id}]"
end

Then(/^no instances are expected to start$/) do
  api_key = FactoryGirl.create(:api_key, permissions: %w(ready_for_start_api_ec2_instances))
  header 'X-Auth-Token', api_key.key
  response = get '/api/ec2_instances/ready_for_start', format: :json
  expect(response.body).to eq '[]'
end

Then(/^"(.*?)" instance is expected to start$/) do |name|
  api_key = FactoryGirl.create(:api_key, permissions: %w(ready_for_start_api_ec2_instances))
  header 'X-Auth-Token', api_key.key
  response = get '/api/ec2_instances/ready_for_start', format: :json
  instance = Ec2Instance.where(name: name).first!
  expect(response.body).to eq "[#{instance.id}]"
end

Then(/^(?:"(.*?)" ,?)+and "(.*?)" instance are expected to start$/) do |*instance_names|
  api_key = FactoryGirl.create(:api_key, permissions: %w(ready_for_start_api_ec2_instances))
  header 'X-Auth-Token', api_key.key
  response = get '/api/ec2_instances/ready_for_start', format: :json
  expect(JSON.parse(response.body)).to match_array Ec2Instance.where(name: instance_names).pluck(:id)
end
