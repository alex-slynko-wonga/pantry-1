Given(/^I am on root page$/) do
  visit '/'
end

Then(/^I should see "(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end

