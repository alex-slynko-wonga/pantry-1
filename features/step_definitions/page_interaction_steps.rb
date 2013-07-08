Then(/^I should see "(.*?)"$/) do |some_text|
  expect(page.text).to include(some_text)
end

When(/^I click (?:on )?"(.*?)"$/) do |text|
  click_on text
end
