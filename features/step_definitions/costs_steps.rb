Given(/^"(.*?)" team has an instance which costs (\d+) dollars for "(.*?)"$/) do |team_name, cost, month_and_year|
  instance = FactoryGirl.create(:ec2_instance, team: Team.find_by_name(team_name))
  (month, year) = month_and_year.split
  month = Date::MONTHNAMES.index(month)
  date = Date.new(year.to_i, month, 1).end_of_month
  FactoryGirl.create(:ec2_instance_cost, ec2_instance: instance, bill_date: date, cost: cost)
end

Given(/^I have a "(.*?)" team$/) do |team_name|
  @team = FactoryGirl.create(:team, name: team_name)
end

Then(/^I see that "(.*?)" team costs (\d+) dollars$/) do |team_name, cost|
  wait_until(5) { page.text.include?(team_name) }
  expect(page.text).to include(cost)
  expect(page).to have_xpath("//table/tbody/tr[td[contains(.,'#{team_name}')]]/td[contains(.,'#{cost}')]")
end

When(/^I select "(.*?)" as date$/) do |date|
  select date
end

Given(/^costs for AWS in "(.*?)" is (\d+) dollars$/) do |month_and_year, cost|
  (month, year) = month_and_year.split
  month = Date::MONTHNAMES.index(month)
  date = Date.new(year.to_i, month, 1).end_of_month
  FactoryGirl.create(:total_cost, cost: cost, bill_date: date)
end

Then(/^I see that total cost are (\d+) dollars$/) do |cost|
  wait_until(5) { page.text.include?(cost) }
  expect(page).to have_xpath("//table/tbody/tr[td[contains(.,'Total')]]/td[contains(.,'#{cost}')]")
end

Then(/^I see that total Pantry costs are (\d+) dollars$/) do |cost|
  p page.text
  wait_until(5) { page.text.include?(cost) }
  expect(page).to have_xpath("//table/tbody/tr[td[contains(.,'Total for instances created in Pantry')]]/td[contains(.,'#{cost}')]")
end
