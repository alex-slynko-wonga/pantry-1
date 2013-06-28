Given(/^I am on root page$/) do
  visit '/'
end

When(/^I am on data bags page$/) do
  visit data_bags_path
end

Then(/^I should be on team page$/) do
  current_url.should =~ /teams/
end

Given(/^I am on the teams page$/) do
  visit "/teams"
end

When(/^I am on packages page$/) do
  visit '/packages'
end
