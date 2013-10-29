Given(/^it has an instance which costs (\d+) dollars for (\d+) months?$/) do |cost, months|
  instance = FactoryGirl.create(:ec2_instance, team: @team)
  today = Date.today
  months.to_i.times { |i| FactoryGirl.create(:ec2_instance_cost, ec2_instance: instance, bill_date: (today - i.months).end_of_month, cost: cost) }
end

Then(/^I see that "(.*?)" team costs (\d+) dollars$/) do |team_name, cost|
  expect(page.text).to include(team_name)
  expect(page.text).to include(cost)
end

When(/^I open details for "(.*?)" team costs$/) do |arg1|
end

Then(/^I see (\d+) and (\d+) as instances cost$/) do |arg1, arg2|
end
