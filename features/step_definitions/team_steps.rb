Given(/^I am on the teams page$/) do
  visit "/teams"
end

When(/^An agent creates a new team named "(.*?)"$/) do |name|
  page.driver.post "/teams", {name: name}
end

Then(/^I expect to see "(.*?)"$/) do |name|
  pending #flesh out with team create story
  #page.should have_content "Name"
end