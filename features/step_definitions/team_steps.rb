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
  page.should have_content "Team"
end

When(/^I click "(.*?)"$/) do |arg1|
  page.should have_content "TeamName"
end