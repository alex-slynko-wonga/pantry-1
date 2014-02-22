When(/^I deactivate current team$/) do
  click_on "Deactivate"
end

When(/^confirm it with "(.*?)"$/) do |value|
  fill_in "confirm", with: value
  click_on "Confirm"
end

