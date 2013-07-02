Given(/^I am on the teams page$/) do
  visit "/teams"
end

When(/^An agent creates a new team named "(.*?)"$/) do |name|
  click_on 'New Team'
  fill_in('team_name', :with => name)
  fill_in('team_description', :with => "TeamDescription")
  click_button("Submit")
end

Then(/^I should be on team page$/) do
  current_url.should =~ /teams/
end

When(/^I click "(.*?)"$/) do |teams|
  click_button teams
end

Given(/^there exists a team named "(.*?)"$/) do |tname|
  @team = FactoryGirl.create(:team)
end

Given(/^I update team "(.*?)" with name "(.*?)"$/) do |oldname, newname|
  visit '/teams'
  visit "/teams/#{@team.id}/edit"
  fill_in('team_name', :with => newname)
  click_button("Submit")
end
