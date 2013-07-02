Given(/^I am on the teams page$/) do
  visit "/teams"
end

When(/^An agent creates a new team named "(.*?)"$/) do |name|
  click_on 'New Team'
  fill_in('team_name', :with => "TeamName")
  fill_in('team_description', :with => "TeamDescription")
  click_button("Create Team")
end

Then(/^I should be on team page$/) do
  current_url.should =~ /teams/
end

When(/^I click "(.*?)"$/) do |arg1|
  page.should have_content "TeamName"
end

Given(/^there exists a team named "(.*?)"$/) do |arg1|
  visit '/teams'
  click_on 'New Team'
  fill_in('team_name', :with => "TeamName")
  fill_in('team_description', :with => "TeamDescription")
  click_button("Create Team")
end

Given(/^I click on "(.*?)"$/) do |arg1|
  click_on arg1
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |arg1, arg2|
  fill_in('team_name', :with => "NewName")
  click_button("Save changes")
end

