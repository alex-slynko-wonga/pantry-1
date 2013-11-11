Given(/^"(.*?)" team has an instance which costs (\d+) dollars for "(.*?)" "(.*?)"$/) do |team_name, cost, month, year|
  instance = FactoryGirl.create(:ec2_instance, team: Team.find_by_name(team_name))
  month = Date::MONTHNAMES.index(month)
  date = DateTime.parse("#{year}-#{month}-01").end_of_month.to_date
  FactoryGirl.create(:ec2_instance_cost, ec2_instance: instance, bill_date: date, cost: cost)
  $stdout.puts Ec2InstanceCost.last.inspect
end

Given(/^I have a "(.*?)" team$/) do |team_name|
  @team = FactoryGirl.create(:team, name: team_name)
end

Then(/^I see that "(.*?)" team costs (\d+) dollars$/) do |team_name, cost|
  expect(page.text).to include(team_name)
  expect(page.text).to include(cost)
end

When(/^I select "(.*?)" as date$/) do |date|
  select date
end
