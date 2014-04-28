When(/^I start maintenance "(.*?)" because of "(.*?)"$/) do |name, message|
  visit "/admin/maintenance_windows/new"
  fill_in 'Name', with: name
  fill_in 'Description', with: "A Maintenance Window"
  fill_in 'Message', with: message
  check 'Enabled'
  click_on 'Save'
end

When(/^I finish maintenance "(.*?)"$/) do |name|
  click_on name
  uncheck 'Enabled'
  click_on 'Save'
end

Then(/^site should be in maintenance mode$/) do
  expect(page).to have_selector ".alert-block", text: "Maintenance Mode Active"
end

Then(/^site should not be in maintenance mode$/) do
  expect(page).not_to have_selector ".alert-block", text: "Maintenance Mode Active"
end

Given(/^site in "(.*?)" maintenance mode$/) do |message|
  FactoryGirl.create(:admin_maintenance_window, :enabled, message: message)
end
